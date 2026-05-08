Use SisArrendaCredito
Go

/*

Declare
   @PnIdRelacion            Integer         = 1,
   @PnId_Unidad             Integer         = 106990,
   @PnIdEstatus             Integer         = 1,
   @PsUsuarioAutoriza       Varchar( 10)    = Null,
   @PsUsuario               Varchar( 10)    = 'ARRENDAN',
   @PnEstatus               Integer         = 0,
   @PsMensaje               Varchar( 250)   = Null;

Begin
   Execute dbo.spc_SO_RelUnidadProductoFinTbl @PnIdRelacion         = @PnIdRelacion,
                                              @PnId_Unidad          = @PnId_Unidad,
                                              @PnIdEstatus          = @PnIdEstatus,
                                              @PsUsuarioAutoriza    = @PsUsuarioAutoriza,
                                              @PsUsuario            = @PsUsuario,
                                              @PnEstatus            = @PnEstatus Output,
                                              @PsMensaje            = @PsMensaje Output;

   Select @PnEstatus error, @PsMensaje Mensaje;
   Return;

End;
Go

*/

--
-- Procedimiento: spc_SO_RelUnidadProductoFinTbl
-- Objetivo:      Procedimiento de Consulta a la Entidad SO_RelUnidadProductoFinTbl
-- Fecha:         01-may-2026
-- Version:       1
--
-- Programador:   Pedro Zambrano
--

Create Or ALter Procedure dbo.spc_SO_RelUnidadProductoFinTbl
  (@PnIdRelacion            Integer         = Null,
   @PnId_Unidad             Integer         = Null,
   @PnIdEstatus             Integer         = Null,
   @PsUsuarioAutoriza       Varchar( 10)    = Null,
   @PsUsuario               Varchar( 10),
   @PnEstatus               Integer         = 0    Output,
   @PsMensaje               Varchar( 250)   = Null Output)
As

Declare
   @w_Error                 Integer,
   @w_registros             Integer,
   @w_prod_fin              Integer,
   @w_operacion             Integer,
   @w_desc_error            Varchar( 250),
   @w_sql                   Varchar(2000),
   @w_fecha                 Datetime,
   @w_comilla               Char(1);

Begin
   Set Nocount       On
   Set Xact_Abort    On
   Set Ansi_Nulls    Off

   Select @PnEstatus       = dbo.Fn_BuscaIdUsuario(@PsUsuario),
          @PsMensaje       = Char(32),
          @w_registros     = 0,
          @w_operacion     = 9999,
          @w_comilla       = Char(39);

  If @PnEstatus != 0
     Begin
        If @PnEstatus Between 9998 And 9999
           Begin
              Set @PsMensaje = dbo.Fn_Busca_MensajeError(@w_operacion, @PnEstatus)
              Goto Salida;
           End;
     End;

  Set @PnEstatus  = 0;

--
-- Validación de la Unidad y el producto Financiero.
--

   If @PnId_Unidad Is Not Null
      Begin
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
               Select @PnEstatus = 9064,
                      @PsMensaje = 'Error.: ' + (dbo.Fn_Busca_MensajeError(@w_operacion, @PnEstatus))

               Goto Salida;
            End

      End

   Set @w_sql = Concat('Select a.idRelacion,        a.Id_Unidad, a.totalFinanciamiento, a.noamort,   ',
                              'a.tasaFinanciamiento, a.idEstatus, b.descripcion Estatus,    ',
                              'Convert(Char(10), a.fechaAlta, 103) fechaAlta, ',
                              'a.usuarioAutoriza,   dbo.Fn_BuscaNombreUsuarioSIAN(dbo.Fn_BuscaIdUsuario(a.usuarioAutoriza)) autorizo, ',
                              'Convert(Char(10),    a.fechaAutoriza, 103) fechaAutorizacion, ',
                              'Convert(Char(10),    a.ultActual,     103) UltfechaActualizacion, ',
                              'a.usuario,           dbo.Fn_BuscaNombreUsuarioSIAN(dbo.Fn_BuscaIdUsuario(a.usuario)) actualizo, ',
                              'a.ipAct ',
                       'From  dbo.SO_RelUnidadProductoFinTbl a With (Nolock) ',
                       'Join  dbo.catGeneralesTbl            b With (Nolock) ',
                       'On    b.tabla         = ', @w_comilla, 'SO_RelUnidadProductoFinTbl', @w_comilla, ' ',
                       'And   b.columna       = ', @w_comilla, 'idEstatus',                  @w_comilla, ' ',
                       'And   b.valor         = a.idEstatus ',
                       'Where a.borradoLogico = 0');

   If @PnIdRelacion Is Not Null
      Begin
         Set @w_sql = Concat(@w_sql, ' And a.idRelacion = ', @PnIdRelacion);
      End


   If @PnId_Unidad Is Not Null
      Begin
         Set @w_sql = Concat(@w_sql, ' And a.Id_unidad = ', @PnId_Unidad);
      End

   If @PnIdEstatus Is Not Null
      Begin
         Set @w_sql = Concat(@w_sql, ' And  idEstatus = ', @PnIdEstatus);
      End

   If @PsUsuarioAutoriza Is Not Null
      Begin
         Set @w_sql = Concat(@w_sql, ' And usuarioAutoriza  = ', @w_comilla, @PsUsuarioAutoriza,                @w_comilla);
      End

   Begin Try
      Execute (@w_sql)
      Set @w_registros = @@Rowcount
   End   Try

   Begin Catch
      Select  @w_Error      = @@Error,
              @w_desc_error = Substring (Error_Message(), 1, 230)
   End   Catch

   If Isnull(@w_Error, 0) <> 0
      Begin
         Select @PnEstatus = @w_error,
                @PsMensaje = 'Error.: ' + @w_desc_error;
         Goto Salida
      End;

   If Isnull(@w_registros, 0) = 0
      Begin
         Select @PnEstatus = 9066,
                @PsMensaje = 'Error.: ' + dbo.Fn_Busca_MensajeError(@w_operacion, @PnEstatus);
      End;


Salida:

   Set Xact_Abort    Off
   Return
End
Go

Declare
   @w_valor          Nvarchar(250) = 'Procedimiento de Consulta a la Entidad SO_RelUnidadProductoFinTbl',
   @w_procedimiento  NVarchar(250) = 'spc_SO_RelUnidadProductoFinTbl';

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
