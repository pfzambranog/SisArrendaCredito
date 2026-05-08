Use SisArrendaCredito
Go

/*

Declare
   @PnIdUnidad              Integer         = 106990,
   @PnProdId                Integer         = 10,
   @PnAmortiz_id            Integer         = 1,
   @PdFecha                 Date            = '2026-05-07',
   @PnSaldoCapital          Decimal(18, 2)  = 1000,
   @PnCapital               Decimal(18, 2)  = 100,
   @PnIntereses             Decimal(18, 2)  = 10,
   @PnIva                   Decimal(18, 2)  = 1.6,
   @PsUsuario               Varchar( 10)    = 'ARRENDAN',
   @PsIpAct                 Varchar( 10)    = Null,
   @PnEstatus               Integer         = 0,
   @PsMensaje               Varchar( 250)   = Char(32);

Begin
   Execute dbo.spa_SO_AmortizacionUnidadProductoTbl @PnIdUnidad     = @PnIdUnidad,
                                                    @PnProdId       = @PnProdId,
                                                    @PnAmortiz_id   = @PnAmortiz_id,
                                                    @PdFecha        = @PdFecha,
                                                    @PnSaldoCapital = @PnSaldoCapital,
                                                    @PnCapital      = @PnCapital,
                                                    @PnIntereses    = @PnIntereses,
                                                    @PnIva          = @PnIva,
                                                    @PsUsuario      = @PsUsuario,
                                                    @PsIpAct        = @PsIpAct,
                                                    @PnEstatus      = @PnEstatus Output,
                                                    @PsMensaje      = @PsMensaje Output;

   Select @PnEstatus error, @PsMensaje Mensaje;
   Return;

End;
Go

*/

--
-- Procedimiento: spa_SO_AmortizacionUnidadProductoTbl
-- Objetivo:      Procedimiento de Alta a la Entidad SO_RelUnidadProductoFinTbl
-- Fecha:         07-may-2026
-- Version:       2
--
-- Programador:   Pedro Zambrano
--

Create Or ALter Procedure dbo.spa_SO_AmortizacionUnidadProductoTbl
  (@PnIdUnidad              Integer,
   @PnProdId                Integer,
   @PnAmortiz_id            Integer,
   @PdFecha                 Date,
   @PnSaldoCapital          Decimal(18, 2)  = 0,
   @PnCapital               Decimal(18, 2),
   @PnIntereses             Decimal(18, 2),
   @PnIva                   Decimal(18, 2)  = 0,
   @PsUsuario               Varchar( 10),
   @PsIpAct                 Varchar( 30)    = Null,
   @PnEstatus               Integer         = 0    Output,
   @PsMensaje               Varchar( 250)   = Null Output)
As

Declare
   @w_Error                 Integer,
   @w_registros             Integer,
   @w_prod_fin              Integer,
   @w_operacion             Integer,
   @w_secuencia             Integer,
   @w_borradoLogico         Integer,
   @w_idEstatus             Integer,
   @w_noamort               Integer,
   @w_total                 Decimal(18, 2),
   @w_monto                 Decimal(18, 2),
   @w_desc_error            Varchar(250),
   @w_fecha                 Datetime;

Begin
   Set Nocount       On
   Set Xact_Abort    On
   Set Ansi_Nulls    Off

   Select @PnEstatus       = dbo.Fn_BuscaIdUsuario(@PsUsuario),
          @PsMensaje       = Null,
          @w_fecha         = Getdate(),
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

   Set @PnEstatus = 0

   If @PnIva > @PnIntereses
      Begin
         Select @PnEstatus = 9076,
                @PsMensaje = dbo.Fn_Busca_MensajeError(@w_operacion, @PnEstatus)

         Goto Salida;

      End

   Select @w_idEstatus       = idEstatus,
          @w_borradoLogico   = @w_borradoLogico,
          @w_noamort         = noamort,
          @w_total           = montoFinanciar
   From   dbo.SO_RelUnidadProductoFinTbl With (Nolock)
   Where  Id_Unidad = @PnIdUnidad
   And    prod_id   = @PnProdId;
   If @@Rowcount = 0
      Begin
         Select @PnEstatus = 9064,
                @PsMensaje = dbo.Fn_Busca_MensajeError(@w_operacion, @PnEstatus)

         Goto Salida;

      End

   If @w_borradoLogico  = 1
      Begin
         Select @PnEstatus = 9068,
                @PsMensaje = dbo.Fn_Busca_MensajeError(@w_operacion, @PnEstatus);

         Goto Salida;

      End

   If @w_idEstatus  = 3
      Begin
         Select @PnEstatus = 9065,
                @PsMensaje = dbo.Fn_Busca_MensajeError(@w_operacion, @PnEstatus)

         Goto Salida;

      End

--

   Select @w_registros = Count(1),
          @w_monto     = Sum(capital)
   From   dbo.SO_AmortizacionUnidadProductoTbl a With (Nolock)
   Where  Id_Unidad    = @PnIdUnidad
   And    prod_id      = @PnProdId;

   If (@w_registros + 1) > @w_noamort
      Begin
         Select @PnEstatus = 9070,
                @PsMensaje = dbo.Fn_Busca_MensajeError(@w_operacion, @PnEstatus)

         Goto Salida;

      End

   If (Isnull(@w_monto, 0) + @PnCapital) > @w_total
      Begin
         Select @PnEstatus = 9071,
                @PsMensaje = dbo.Fn_Busca_MensajeError(@w_operacion, @PnEstatus)

         Goto Salida;

      End

   Select Top 1 @w_idEstatus = idEstatus
   From   dbo.SO_AmortizacionUnidadProductoTbl a With (Nolock)
   Where  Id_Unidad     = @PnIdUnidad
   And    prod_id       = @PnProdId
   And    Amortiz_id    = @PnAmortiz_id;
   If @@Rowcount > 0
      Begin
         Select @PnEstatus = 9072,
                @PsMensaje = dbo.Fn_Busca_MensajeError(@w_operacion, @PnEstatus)

         Goto Salida;

      End

   If Exists ( Select Top 1 1
               From   dbo.SO_AmortizacionUnidadProductoTbl
               Where  Id_Unidad   = @PnIdUnidad
               And    prod_id     = @PnProdId
               And    @PdFecha   <= fechaAmort)
      Begin
         Select @PnEstatus = 9075,
                @PsMensaje = dbo.Fn_Busca_MensajeError(@w_operacion, @PnEstatus);

         Goto Salida;

      End

   Begin Try
      Insert Into dbo.SO_AmortizacionUnidadProductoTbl
     (Id_Unidad,    prod_id, amortiz_id, fechaAmort,
      saldoCapital, capital, intereses,  iva,
      usuario,      ipAct)
      Select @PnIdUnidad,      @PnProdId,   @PnAmortiz_id, @PdFecha,
             @PnSaldoCapital,  @PnCapital,  @PnIntereses,  @PnIva,
             @PsUsuario,       @PsIpAct;
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
   @w_valor          Nvarchar(250) = 'Procedimiento de Alta a la Entidad SO_AmortizacionUnidadProductoTbl',
   @w_procedimiento  NVarchar(250) = 'spa_SO_AmortizacionUnidadProductoTbl';

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