Use SisArrendaCredito
Go

/*

Declare
   @PnIdRelacion            Integer         = 2,
   @PnAmortiz_id            Integer         = 3,
   @PsUsuario               Varchar( 10)    = 'ARRENDAN',
   @PnEstatus               Integer         = 0,
   @PsMensaje               Varchar( 250)   = Null;

Begin
   Execute dbo.spd_SO_RelUnidadProductoFinAmorTbl   @PnIdRelacion         = @PnIdRelacion,
                                                    @PnAmortiz_id         = @PnAmortiz_id,
                                                    @PsUsuario            = @PsUsuario,
                                                    @PnEstatus            = @PnEstatus Output,
                                                    @PsMensaje            = @PsMensaje Output;

   Select @PnEstatus error, @PsMensaje Mensaje;
   Return;

End;
Go

*/

--
-- Procedimiento: spd_SO_RelUnidadProductoFinAmorTbl
-- Objetivo:      Procedimiento de Baja de Registros a la Entidad SO_RelUnidadProductoFinAmorTbl
-- Fecha:         02-may-2026
-- Version:       1
--
-- Programador:   Pedro Zambrano
--

Create Or Alter Procedure dbo.spd_SO_RelUnidadProductoFinAmorTbl
  (@PnIdRelacion            Integer,
   @PnAmortiz_id            Integer,
   @PsUsuario               Varchar( 10),
   @PnEstatus               Integer         = 0    Output,
   @PsMensaje               Varchar( 250)   = Null Output)
As

Declare
   @w_Error                 Integer,
   @w_operacion             Integer,
   @w_desc_error            Varchar( 250),
   @w_sql                   Varchar(2000),
   @w_comilla               Char(1);

Begin
   Set Nocount       On
   Set Xact_Abort    On
   Set Ansi_Nulls    Off

   Select @PnEstatus       = dbo.Fn_BuscaIdUsuario(@PsUsuario),
          @PsMensaje       = Char(32),
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

   If Not Exists (Select Top 1 1
                  From   dbo.SO_RelUnidadProductoFinAmorTbl With (Nolock)
                  Where  idRelacion = @PnIdRelacion
                  And    amortiz_id = @PnAmortiz_id)
      Begin
         Select @PnEstatus = 9064,
                @PsMensaje = dbo.Fn_Busca_MensajeError(@w_operacion, @PnEstatus)

         Goto Salida;

      End

  Set @PnEstatus  = 0;

  Set @w_sql = Concat('Delete dbo.SO_RelUnidadProductoFinAmorTbl ',
                      'Where  idRelacion = ', @PnIdRelacion, ' ',
                      'And    amortiz_id = ', @PnAmortiz_id);
   Begin Try
      Execute (@w_sql)
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

Salida:

   Set Xact_Abort    Off
   Return
End
Go

Declare
   @w_valor          Nvarchar(250) = 'Procedimiento de Baja de Registros a la Entidad SO_RelUnidadProductoFinAmorTbl',
   @w_procedimiento  NVarchar(250) = 'spd_SO_RelUnidadProductoFinAmorTbl';

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
