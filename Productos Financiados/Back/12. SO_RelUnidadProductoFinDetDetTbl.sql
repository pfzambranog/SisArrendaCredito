Use SisArrendaCredito
Go

/*

Declare
   @PnIdRelacion            Integer         = 2,
   @PnProd_id               Integer         = 26,
   @PnSecuencia             Integer         = 1,
   @PnBajaReal              Integer         = 0,
   @PsUsuario               Varchar( 10)    = 'ARRENDAN',
   @PsIpAct                 Varchar( 10)    = Null,
   @PnEstatus               Integer         = 0,
   @PsMensaje               Varchar( 250)   = Null;

Begin
   Execute dbo.spd_SO_RelUnidadProductoFinDetTbl @PnIdRelacion         = @PnIdRelacion,
                                                    @PnProd_id            = @PnProd_id,
                                                    @PnSecuencia          = @PnSecuencia,
                                                    @PnBajaReal           = @PnBajaReal,
                                                    @PsUsuario            = @PsUsuario,
                                                    @PsIpAct              = @PsIpAct,
                                                    @PnEstatus            = @PnEstatus Output,
                                                    @PsMensaje            = @PsMensaje Output;

   Select @PnEstatus error, @PsMensaje Mensaje;
   Return;

End;
Go

*/

--
-- Procedimiento: spd_SO_RelUnidadProductoFinDetTbl
-- Objetivo:      Procedimiento de Baja de Registros a la Entidad SO_RelUnidadProductoFinDetTbl
--                @PnBajaReal = 0 - Actualiza el campo borradoLogico = 1
--                @PnBajaReal = 1 - Baja Física del registro
-- Fecha:         01-may-2026
-- Version:       1
--
-- Programador:   Pedro Zambrano
--

Create Or Alter Procedure dbo.spd_SO_RelUnidadProductoFinDetTbl
  (@PnIdRelacion            Integer,
   @PnProd_id               Integer,
   @PnSecuencia             Integer,
   @PnBajaReal              Integer         = 0,
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
          @w_comilla       = Char(39),
          @w_fecha         = Getdate(),
          @PsIpAct         = Isnull(@PsIpAct, dbo.Fn_BuscaDireccionIP());

  If @PnEstatus != 0
     Begin
        If @PnEstatus Between 9998 And 9999
           Begin
              Set @PsMensaje = dbo.Fn_Busca_MensajeError(@w_operacion, @PnEstatus)
              Goto Salida;
           End;
     End;

   If Not Exists (Select Top 1 1
                  From   dbo.SO_RelUnidadProductoFinDetTbl With (Nolock)
                  Where  idRelacion = @PnIdRelacion
                  And    prod_id    = @PnProd_id
                  And    secuencia  = @PnSecuencia)
      Begin
         Select @PnEstatus = 9064,
                @PsMensaje = dbo.Fn_Busca_MensajeError(@w_operacion, @PnEstatus)

         Goto Salida;

      End

  Set @PnEstatus  = 0;

   If @PnBajaReal = 1
      Begin
         Set @w_sql = Concat('Delete dbo.SO_RelUnidadProductoFinDetTbl ',
                             'Where  idRelacion = ', @PnIdRelacion, ' ',
                             'And    prod_id    = ', @PnProd_id,   ' ',
                             'And    secuencia  = ', @PnSecuencia);
      End
   Else
      Begin
         Set @w_sql = Concat('Update dbo.SO_RelUnidadProductoFinDetTbl ',
                             'Set    idEstatus     = 0, ',
                                    'borradoLogico = 1, ',
                                    'ultActual     = ', @w_comilla, Cast(@w_fecha As Varchar), @w_comilla, ', ',
                                    'usuario       = ', @w_comilla, @PsUsuario,                @w_comilla, ', ',
                                    'ipAct         = ', @w_comilla, @PsIpAct,                  @w_comilla,
                             'Where  idRelacion    = ', @PnIdRelacion,
                             'And    prod_id       = ', @PnProd_id,   ' ',
                             'And    secuencia     = ', @PnSecuencia);
      End

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
   @w_valor          Nvarchar(250) = 'Procedimiento de Baja de Registros a la Entidad SO_RelUnidadProductoFinDetTbl',
   @w_procedimiento  NVarchar(250) = 'spd_SO_RelUnidadProductoFinDetTbl';

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
