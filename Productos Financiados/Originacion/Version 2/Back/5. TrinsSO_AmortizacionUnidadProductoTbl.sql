Use SisArrendaCredito
Go

--
-- Diparador:     TrinsSO_AmortizacionUnidadProductoTbl
-- Objetivo:      Disparador de Alta y Actualización relacionado a la Entidad SO_AmortizacionUnidadProductoTbl
-- Fecha:         07-may-2026
-- Version:       2
--
-- Programador:   Pedro Zambrano
--

Create Or Alter Trigger dbo.TrinsSO_AmortizacionUnidadProductoTbl
On     dbo.SO_AmortizacionUnidadProductoTbl
After  Insert, Update
As

Declare
   @w_Id_unidad             Integer,
   @w_prod_id               Integer,
   @w_amortiz_id            Integer,
   @w_registros             Integer,
   @w_noamort               Integer,
   @w_prod_fin              Integer,
   @w_total                 Decimal(18, 2),
   @w_monto                 Decimal(18, 2),
   @w_capital               Decimal(18, 2),
   @w_intereses             Decimal(18, 2),
   @w_iva                   Decimal(18, 2),
   @w_fecha                 Date,
   @w_idEstatus             Tinyint,
   @w_borradoLogico         Bit,
   @w_usuario               Varchar( 10),
   @w_operacion             Integer,
   @w_estatus               Integer,
   @w_mensaje               Varchar(250);

Begin

   Select @w_Id_unidad           = Id_unidad,
          @w_prod_id             = prod_id,
          @w_amortiz_id          = amortiz_id,
          @w_fecha               = fechaAmort,
          @w_capital             = capital,
          @w_intereses           = intereses,
          @w_iva                 = iva,
          @w_idEstatus           = idEstatus,
          @w_usuario             = usuario,
          @w_operacion           = 9999,
          @w_estatus             = dbo.Fn_BuscaIdUsuario(a.usuario)
   From   Inserted a;

  If @w_estatus != 0
     Begin
        If @w_estatus Between 9998 And 9999
           Begin
              Set @w_mensaje = dbo.Fn_Busca_MensajeError(@w_operacion, @w_estatus)
              Raiserror (@w_mensaje, 16, 1)
              Rollback Transaction
              Return
           End;
     End;


--
-- Validación del identificador del estatus
--

   If Isnull(@w_idEstatus, 0) Not In (0, 1)
      Begin
         Select @w_estatus = 8033,
                @w_mensaje = dbo.Fn_Busca_MensajeError(@w_operacion, @w_estatus);

         Raiserror (@w_mensaje, 16, 1)
         Rollback Transaction
         Return

      End;

   Set @w_estatus = 0

--
-- Validación de la relación Unidad-Producto.
--

   Select @w_idEstatus       = idEstatus,
          @w_borradoLogico   = @w_borradoLogico,
          @w_noamort         = noamort,
          @w_total           = montoFinanciar
   From   dbo.SO_RelUnidadProductoFinTbl With (Nolock)
   Where  Id_unidad = @w_Id_unidad
   And    prod_id   = @w_prod_id;
   If @@Rowcount = 0
      Begin
         Select @w_estatus = 9064,
                @w_mensaje = dbo.Fn_Busca_MensajeError(@w_operacion, @w_estatus)

         Raiserror (@w_mensaje, 16, 1)
         Rollback Transaction
         Return

      End

   If @w_borradoLogico  = 1
      Begin
         Select @w_estatus = 9068,
                @w_mensaje = dbo.Fn_Busca_MensajeError(@w_operacion, @w_estatus);

         Raiserror (@w_mensaje, 16, 1)
         Rollback Transaction
         Return

      End

   If @w_idEstatus  = 3
      Begin
         Select @w_estatus = 9065,
                @w_mensaje = dbo.Fn_Busca_MensajeError(@w_operacion, @w_estatus)

         Raiserror (@w_mensaje, 16, 1)
         Rollback Transaction
         Return

      End

   If @w_idEstatus  > 3
      Begin
         Select @w_estatus = 9074,
                @w_mensaje = dbo.Fn_Busca_MensajeError(@w_operacion, @w_estatus)

         Raiserror (@w_mensaje, 16, 1)
         Rollback Transaction
         Return

      End

--

   If @w_iva >= @w_intereses
      Begin
         Select @w_estatus = 9076,
                @w_mensaje = dbo.Fn_Busca_MensajeError(@w_operacion, @w_estatus)

         Raiserror (@w_mensaje, 16, 1)
         Rollback Transaction
         Return

      End

   Select @w_registros = Count(1),
          @w_monto     = Sum(capital)
   From   dbo.SO_AmortizacionUnidadProductoTbl a With (Nolock)
   Where  Id_unidad    = @w_Id_unidad
   And    prod_id      = @w_prod_id;

   If (@w_registros + 1) > @w_noamort
      Begin
         Select @w_estatus = 9070,
                @w_mensaje = dbo.Fn_Busca_MensajeError(@w_operacion, @w_estatus)

         Raiserror (@w_mensaje, 16, 1)
         Rollback Transaction
         Return

      End

   If (@w_monto + @w_capital) > @w_total
      Begin
         Select @w_estatus = 9071,
                @w_mensaje = dbo.Fn_Busca_MensajeError(@w_operacion, @w_estatus)

         Raiserror (@w_mensaje, 16, 1)
         Rollback Transaction
         Return

      End

   If Exists ( Select Top 1 1
               From   dbo.SO_AmortizacionUnidadProductoTbl
               Where  Id_unidad    = @w_Id_unidad
               And    prod_id      = @w_prod_id
               And    @w_fecha     < fechaAmort)
      Begin
         Select @w_estatus = 9075,
                @w_mensaje = dbo.Fn_Busca_MensajeError(@w_operacion, @w_estatus);

         Raiserror (@w_mensaje, 16, 1)
         Rollback Transaction
         Return

      End

   Select Top 1 @w_prod_fin = c.prod_fin_id
   From   dbo.SO_SolCotizacion a With (Nolock)
   Join   dbo.SO_Unidades b      With (Nolock)
   On     b.idSolicitud = a.idSolicitud
   Join   dbo.so_tipos c         With (Nolock)
   On     c.IdTipo      = a.IdTipo
   Where  b.Id_Unidad   = @w_Id_Unidad;
   If @@Rowcount =  0
      Begin
         Select @w_estatus = 6014,
                @w_mensaje = 'Error.: ' + (dbo.Fn_Busca_MensajeError(@w_operacion, @w_estatus))

         Raiserror (@w_mensaje, 16, 1)
         Rollback Transaction
         Return
      End

   If @w_prod_fin != 1
      Begin
         Select @w_estatus = 10014,
                @w_mensaje = dbo.Fn_Busca_MensajeError(@w_operacion, @w_estatus);

         Raiserror (@w_mensaje, 16, 1)
         Rollback Transaction
         Return
      End

   Return

End
Go
