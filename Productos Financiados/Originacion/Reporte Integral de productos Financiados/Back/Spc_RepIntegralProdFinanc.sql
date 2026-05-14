Use SisArrendaCredito
Go

/*

Declare
   @PnId_Unidad             Integer         = 106990,
   @PsUsuario               Varchar( 10)    = 'ARRENDAN',
   @PnEstatus               Integer         = 0,
   @PsMensaje               Varchar( 250)   = Char(32);

Begin
   Execute dbo.Spc_RepIntegralProdFinanc @PnId_Unidad   = @PnId_Unidad,
                                         @PsUsuario     = @PsUsuario,
                                         @PnEstatus     = @PnEstatus Output,
                                         @PsMensaje     = @PsMensaje Output;

   If @PnEstatus != 0
      Begin
         Select @PnEstatus error, @PsMensaje Mensaje;
     End;

   Return;

End;
Go

*/

--
-- Procedimiento: Spc_RepIntegralProdFinanc
-- Objetivo:      Procedimiento dque genera el Reporte Integral de productos Financiados
-- Fecha:         08-may-2026
-- Version:       1
--
-- Programador:   Pedro Zambrano
--

Create Or Alter Procedure dbo.Spc_RepIntegralProdFinanc
  (@PnId_Unidad             Integer,
   @PsUsuario               Varchar( 10),
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
   @w_desc_error            Varchar(250),
--
   @w_RentaMin              Decimal(18, 2),
   @w_KmMax                 Decimal(18, 2),
   @w_RentaMinGas           Decimal(18, 2),
   @w_RentaMinHib           Decimal(18, 2),
   @w_iva                   Decimal(18, 2),
   @w_unidadHibrida         Bit;

Begin
   Set Nocount       On
   Set Xact_Abort    On
   Set Ansi_Nulls    Off

   Select @PnEstatus       = dbo.Fn_BuscaIdUsuario(@PsUsuario),
          @PsMensaje       = Char(32),
          @w_registros     = 0,
          @w_operacion     = 9999,
          @w_unidadHibrida = 0;

--
-- Validaciones
--

--
-- Estatus del Usuario que solicita la generación del reporte.
--

  If @PnEstatus != 0
     Begin
        If @PnEstatus Between 9998 And 9999
           Begin
              Set @PsMensaje = dbo.Fn_Busca_MensajeError(@w_operacion, @PnEstatus);
              Goto Salida;
           End;
     End;

   Set @PnEstatus = 0;

--
-- Validación de la disponibilidad de la Unidad seleccionada a traves del parametro de entrada @PnId_Unidad
--

   Select top  1 @w_unidadHibrida = unidadHibrida
   From   dbo.SO_Cot_Articulos   With (Nolock)
   Where  id_articulo = @PnId_Unidad
   If @@Rowcount = 0
      Begin
         Select @PnEstatus = 6014,
                @PsMensaje = dbo.Fn_Busca_MensajeError(@w_operacion, @PnEstatus)

         Goto Salida;
      End

--
-- Validación de Productos Financiados relacionados a la unidad.
--

   If Not Exists ( Select Top 1 1
                   From   dbo.SO_RelUnidadProductoFinTbl With (Nolock)
                   Where  id_unidad     = @PnId_Unidad
                   And    borradoLogico = 0)
      Begin
         Select @PnEstatus = 10011,
                @PsMensaje = dbo.Fn_Busca_MensajeError(@w_operacion, @PnEstatus)

         Goto Salida;
      End

--
-- Búsqueda de Parámetros.
--

--
-- Valor Renta Mínima SIN IVA para Autos Híbridos/Eléctricos
--

   Select @w_RentaMinHib   = Valor
   From   dbo.parametros With (Nolock)
   Where  id = 421;
   If @@Rowcount = 0 Or
      Isnull(@w_RentaMinHib, 0) = 0
      Begin
         Select @PnEstatus = 10017,
                @PsMensaje = dbo.Fn_Busca_MensajeError(@w_operacion, @PnEstatus);
         Goto Salida;
      End

--
-- Valor Renta Mínima SIN IVA para Autos de Gasolina
--

   Select @w_RentaMinGas   = Valor
   From   dbo.parametros With (Nolock)
   Where  id = 422;
   If @@Rowcount = 0 Or
      Isnull(@w_RentaMinGas, 0) = 0
      Begin
         Select @PnEstatus = 10018,
                @PsMensaje = dbo.Fn_Busca_MensajeError(@w_operacion, @PnEstatus);
         Goto Salida;
      End

--
-- Valor de la tasa del IVA Vigente.
--

   Select @w_iva   = Valor
   From   dbo.parametros With (Nolock)
   Where  id = 3;
   If @@Rowcount = 0 Or
      Isnull(@w_iva, 0) = 0
      Begin
         Select @PnEstatus = 10019,
                @PsMensaje = dbo.Fn_Busca_MensajeError(@w_operacion, @PnEstatus);
         Goto Salida;
      End

--
-- Cálculo de Variables Base
--

   Select @w_RentaMin    = Case When @w_unidadHibrida = 1
                                Then @w_RentaMinHib
                                Else @w_RentaMinGas
                           End,
          @w_KmMax       = Case When @w_unidadHibrida = 1
                                Then @w_RentaMinHib * 2
                                Else @w_RentaMinGas * 2
                           End;

--
-- Creación de Tablas Temporales
--

   Create table #TempRepIntegralTbl
   (id_unidad         Integer        Not Null,
    amortiz_id        Integer        Not Null,
-- Financiamiento
    saldoCapitalFin   Integer        Not Null Default 0,
    PagoInteresFin    Decimal(18, 2) Not Null Default 0,
    IVAFinancia       Decimal(18, 2) Not Null Default 0,
    PagoCapitalFin    Decimal(18, 2) Not Null Default 0,
-- Arrendamiento
    saldoCapitalArr   Integer        Not Null Default 0,
    PagoInteresArr    Decimal(18, 2) Not Null Default 0,
    IVAArrendamiento  Decimal(18, 2) Not Null Default 0,
    PagoCapitalArr    Decimal(18, 2) Not Null Default 0,
--
    unidadHibrida     Bit            Not Null Default 0,     -- 1 Si la Unidad es Hibrida,
    RentaConIva       Decimal(18, 2) Not Null Default 0,
    KmConIva          Decimal(18, 2) Not Null Default 0,     -- Kilometraje con Iva.
    Constraint TempRepIntegralPk
   Primary Key (id_unidad, amortiz_id))

   Begin Try
      Insert Into #TempRepIntegralTbl
      (id_unidad,        amortiz_id,       saldoCapitalArr, PagoInteresArr,
       IVAArrendamiento, PagoCapitalArr,   unidadHibrida)
       Select a.Id_Unidad, b.noPago,       b.saldoCapital, b.PagoIntereses,
              b.Iva,       b.PagoCapital,  @w_unidadHibrida
       From   dbo.SO_Unidades a                 With (Nolock)
       Join   dbo.SO_SolTabla_Condiciones_art b With (NOLOCK)
       On     b.IdArticulo  = a.Id_articulo
       Where  a.Id_Unidad   = @PnId_Unidad;
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


   Begin Try
      Merge #TempRepIntegralTbl As tgt
      Using (Select Id_Unidad,     amortiz_id, Sum(saldoCapital) saldoCapital, Sum(intereses) intereses,
                    Sum(iva) iva,  Sum(capital) capital
             From   dbo.SO_AmortizacionUnidadProductoTbl With (Nolock)
             Where  Id_Unidad = @PnId_Unidad
             Group  By Id_Unidad, amortiz_id) As src
      On    tgt.id_unidad  = src.Id_Unidad
      And   tgt.amortiz_id = src.amortiz_id
      When  Matched Then
            Update Set saldoCapitalFin = src.saldoCapital,
                       PagoInteresFin  = src.intereses,
                       IVAFinancia     = src.iva,
                       PagoCapitalFin  = src.capital

      When  Not Matched Then
            Insert (id_unidad,   amortiz_id,      saldoCapitalFin, PagoInteresFin,
                    IVAFinancia, PagoCapitalFin,  unidadHibrida)
            Values (src.Id_Unidad, src.amortiz_id, src.saldoCapital, src.intereses,
                    src.iva,       src.capital,   @w_unidadHibrida);
   End   Try

   Begin Catch
      Select  @w_Error      = @@Error,
              @w_desc_error = Substring (Error_Message(), 1, 230)
   End   Catch

   If Isnull(@w_Error, 0) <> 0
      Begin
         Select @PnEstatus = @w_error,
                @PsMensaje = 'Error.: ' + @w_desc_error;

         Goto Salida;
      End;

--
-- Aplicación de las reglas facilitadas
--
-- Cuando la Renta Total SIN IVA es MAYOR al valor Kilometraje Ilimitado Máximo SIN IVA:
--
--    1.- Se llena primero el valor de la columna KILOMETRAJE CON IVA
--    2.- El restante se va a la columna RENTA CON IVA
--
-- Cuando la Renta Total SIN IVA es MENOR al valor Kilometraja Ilimitado Máximo SIN IVA:
--
--    1.- Se llena primero el valor de la columna RENTA CON IVA
--    2.- El restante se va a la columna KILOMETRAJE CON IVA

   Begin Try
      Update a
      Set    KmConIva    = Case When base.renta > @w_KmMax
                                Then Round(@w_KmMax + (@w_KmMax * @w_iva) / 100.00, 2)
                                Else
                                   Case When base.renta > @w_RentaMin
                                        Then Round(calc.kmBase + (calc.kmBase * @w_iva) / 100.00, 2)
                                        Else 0
                                   End
                           End,

             RentaConIva = Case When base.renta > @w_KmMax
                                Then Round(calc.rentaBase + (calc.rentaBase * @w_iva) / 100.00, 2)
                                Else
                                Case
                                   When base.renta >= @w_RentaMin
                                   Then Round(@w_RentaMin + (@w_RentaMin * @w_iva) / 100.00, 2)
                                   Else Round(base.renta  + (base.renta  * @w_iva) / 100.00, 2)
                                End
                           End
       From #TempRepIntegralTbl a
       Cross Apply (Select renta      = (a.PagoInteresArr + a.PagoCapitalArr)) base
       Cross Apply (Select kmBase     = base.renta - @w_RentaMin,
                           rentaBase  = base.renta - @w_KmMax) calc

   End   Try

   Begin Catch
      Select  @w_Error      = @@Error,
              @w_desc_error = Substring (Error_Message(), 1, 230)
   End   Catch

   If Isnull(@w_Error, 0) <> 0
      Begin
         Select @PnEstatus = @w_error,
                @PsMensaje = 'Error.: ' + @w_desc_error;

         Goto Salida;
      End;

--
-- Salida del Reporte
--

   Begin Try
      Select amortiz_id "No. de Pago.",    saldoCapitalFin + saldoCapitalArr "Saldo Capital",
             PagoInteresFin +  PagoInteresArr "Pago Intereses",  IVAFinancia   "IVA Financiamiento",
             PagoCapitalFin +  PagoCapitalArr "Pago Capital",
             PagoInteresFin +  PagoInteresArr + IVAFinancia + PagoCapitalFin +  PagoCapitalArr "Subtotal",
             IVAArrendamiento "IVA Arrendamiento", PagoInteresFin +  PagoInteresArr + IVAFinancia + PagoCapitalFin +  PagoCapitalArr + IVAArrendamiento "Pago Total",
             RentaConIva "Renta Con Iva", KmConIva "Kilometraje Con Iva"
      From #TempRepIntegralTbl;
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
   @w_valor          Nvarchar(250) = 'Procedimiento dque genera el Reporte Integral de productos Financiados',
   @w_procedimiento  NVarchar(250) = 'Spc_RepIntegralProdFinanc';

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

