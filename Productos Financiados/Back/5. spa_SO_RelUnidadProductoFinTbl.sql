Use SisArrendaCredito
Go

/*

Declare
   @PnId_Unidad             Integer         = 106990,
   @PnTotalFinanciamiento   Decimal(18, 2)  = 1200,
   @PnNoamort               Integer         = 12,
   @PnTasaFinanciamiento    Decimal(18, 4)  = 10,
   @PnIdEstatus             Integer         = 1,
   @PsUsuarioAutoriza       Varchar( 10)    = Null,
   @PdFechaAutoriza         Datetime        = Null,
   @PdUltActual             Datetime        = Null,
   @PsUsuario               Varchar( 10)    = 'ARRENDAN',
   @PsIpAct                 Varchar( 10)    = Null,
   @PnEstatus               Integer         = 0,
   @PsMensaje               Varchar( 250)   = Null;

Begin
   Execute dbo.spa_SO_RelUnidadProductoFinTbl @PnId_Unidad           = @PnId_Unidad,
                                              @PnTotalFinanciamiento = @PnTotalFinanciamiento,
                                              @PnNoamort             = @PnNoamort,
                                              @PnTasaFinanciamiento  = @PnTasaFinanciamiento,
                                              @PnIdEstatus           = @PnIdEstatus,
                                              @PsUsuarioAutoriza     = @PsUsuarioAutoriza,
                                              @PdFechaAutoriza       = @PdFechaAutoriza,
                                              @PdUltActual           = @PdUltActual,
                                              @PsUsuario             = @PsUsuario,
                                              @PsIpAct               = @PsIpAct,
                                              @PnEstatus             = @PnEstatus Output,
                                              @PsMensaje             = @PsMensaje Output;

   Select @PnEstatus error, @PsMensaje Mensaje;
   Return;

End;
Go

*/

--
-- Procedimiento: spa_SO_RelUnidadProductoFinTbl
-- Objetivo:      Procedimiento de Alta a la Entidad SO_RelUnidadProductoFinTbl
-- Fecha:         30-Abr-2026
-- Version:       1
--
-- Programador:   Pedro Zambrano
--

Create Or ALter Procedure dbo.spa_SO_RelUnidadProductoFinTbl
  (@PnId_Unidad             Integer,
   @PnTotalFinanciamiento   Decimal(18, 2),
   @PnNoamort               Integer,
   @PnTasaFinanciamiento    Decimal(18, 4),
   @PnIdEstatus             Integer         = 1,
   @PsUsuarioAutoriza       Varchar( 10)    = Null,
   @PdFechaAutoriza         Datetime        = Null,
   @PdUltActual             Datetime        = Null,
   @PsUsuario               Varchar( 10),
   @PsIpAct                 Varchar( 10)    = Null,
   @PnEstatus               Integer         = 0    Output,
   @PsMensaje               Varchar( 250)   = Null Output)
As

Declare
   @w_Error                 Integer,
   @w_registros             Integer,
   @w_prod_fin              Integer,
   @w_operacion             Integer,
   @w_desc_error            Varchar(250),
   @w_fecha                 Datetime;

Begin
   Set Nocount       On
   Set Xact_Abort    On
   Set Ansi_Nulls    Off

   Select @PnEstatus       = dbo.Fn_BuscaIdUsuario(@PsUsuario),
          @PsMensaje       = Null,
          @w_fecha         = Isnull(@PdUltActual, Getdate()),
          @w_registros     = 0,
          @w_operacion     = 9999,
          @PsIpAct         = Isnull(@PsIpAct, dbo.Fn_BuscaDireccionIP());


  If @PnEstatus != 0
     Begin
        If @PnEstatus Between 9998 And 9999
           Begin
              Set @PsMensaje = dbo.Fn_Busca_MensajeError(@w_operacion, @PnEstatus)
              Goto Salida;
           End;
     End;

   If @PsUsuarioAutoriza Is Not NUll Or
      @PnIdEstatus        = 2
      Begin
         Set @PnEstatus       = dbo.Fn_BuscaIdUsuario(@PsUsuarioAutoriza);

         If @PnEstatus Between 9998 And 9999
            Begin
               If @PnEstatus = 999
                  Begin
                     Set @PnEstatus = 9061
                  End
               Else
                  Begin
                     Set @PnEstatus = 9062
                  End

               Set @PsMensaje = dbo.Fn_Busca_MensajeError(@w_operacion, @PnEstatus)
               Goto Salida

            End

         If @PdFechaAutoriza Is Null
            Begin
               Select @PnEstatus = 9063,
                      @PsMensaje = dbo.Fn_Busca_MensajeError(@w_operacion, @PnEstatus);

               Goto Salida
            End;

      End;

   If Not Exists (Select Top 1 1 
                  From   dbo.catGeneralesTbl With (Nolock)
                  Where  tabla   = 'SO_RelUnidadProductoFinTbl'
                  And    columna = 'idEstatus'
                  And    Valor   = @PnIdEstatus)
      Begin
         Select @PnEstatus = 8033,
                @PsMensaje = dbo.Fn_Busca_MensajeError(@w_operacion, @PnEstatus);

               Goto Salida
            End;

   Set @PnEstatus = 0
   
--
-- Validación de la Unidad y el producto Financiero.
--

   Select Top 1 @w_prod_fin = c.prod_fin_id
   From   dbo.SO_SolCotizacion a With (Nolock)
   Join   dbo.SO_Unidades b      With (Nolock)
   On     b.idSolicitud = a.idSolicitud
   Join   dbo.so_tipos c         With (Nolock)
   On     c.IdTipo      = a.IdTipo
   Where   b.Id_Unidad  = @PnId_Unidad;
   If @@Rowcount =  0
      Begin
         Select @PnEstatus = 6014,
                @PsMensaje = 'Error.: ' + (dbo.Fn_Busca_MensajeError(@w_operacion, @PnEstatus))

         Goto Salida;
      End

   If @w_prod_fin != 1
      Begin
         Select @PnEstatus = 10014,
                @PsMensaje = dbo.Fn_Busca_MensajeError(@w_operacion, @PnEstatus);

         Goto Salida;
      End

   Begin Try
      Insert Into dbo.SO_RelUnidadProductoFinTbl
     (Id_Unidad, totalFinanciamiento, noamort,       tasaFinanciamiento,
      idEstatus, usuarioAutoriza,    fechaAutoriza, usuario,
      UltActual, ipAct)
      Select @PnId_Unidad, @PnTotalFinanciamiento, @PnNoamort,       @PnTasaFinanciamiento,
             @PnIdEstatus, @PsUsuarioAutoriza,    @PdFechaAutoriza, @PsUsuario,
             @w_fecha,     @PsIpAct;
      Set @PsMensaje = @@Identity;

   End   Try

   Begin Catch
      Select  @w_Error      = @@Error,
              @w_desc_error = Substring (Error_Message(), 1, 230)
   End   Catch

   If Isnull(@w_Error, 0) <> 0
      Begin
         Select @PnEstatus = @w_error,
                @PsMensaje = 'Error.: ' + @w_desc_error;
      End;


Salida:

   Set Xact_Abort    Off
   Return
End
Go

Declare
   @w_valor          Nvarchar(250) = 'Procedimiento de Alta a la Entidad SO_RelUnidadProductoFinTbl',
   @w_procedimiento  NVarchar(250) = 'spa_SO_RelUnidadProductoFinTbl';

If Not Exists (Select Top 1 1
               From   sys.extended_properties a
               Join   sysobjects  b
               On     b.xtype   = 'P'
               And    b.name    = @w_procedimiento
               And    b.id      = a.major_id)
   Begin
      Execute  sp_addextendedproperty @name       = N'MS_Description',
                                      @value      = @w_valor,
                                      @level0type = 'Schema',
                                      @level0name = N'dbo',
                                      @level1type = 'Procedure',
                                      @level1name = @w_procedimiento

   End
Else
   Begin
      Execute sp_updateextendedproperty @name       = 'MS_Description',
                                        @value      = @w_valor,
                                        @level0type = 'Schema',
                                        @level0name = N'dbo',
                                        @level1type = 'Procedure',
                                        @level1name = @w_procedimiento
   End
Go