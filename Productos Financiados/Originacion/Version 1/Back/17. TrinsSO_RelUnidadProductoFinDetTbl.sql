--
-- Diparador:     TrinsSO_RelUnidadProductoFinDetTbl
-- Objetivo:      Disparador de Alta y Update relacionado a la Entidad SO_RelUnidadProductoFinDetTbl
-- Fecha:         02-may-2026
-- Version:       1
--
-- Programador:   Pedro Zambrano
--

Create Or Alter Trigger dbo.TrinsSO_RelUnidadProductoFinDetTbl
On     dbo.SO_RelUnidadProductoFinDetTbl
After  Insert, Update
As

Declare
   @w_idRelacion            Integer,
   @w_prod_id               Integer,
   @w_secuencia             Integer,
   @w_precioLista           Decimal(8, 2),
   @w_descuento             Decimal(8, 2),
   @w_precioneto            Decimal(8, 2),
   @w_tasaIva               Decimal(8, 2),
   @w_montoIva              Decimal(8, 2),
   @w_precioTotal           Decimal(8, 2),
   @w_usuario               Varchar(10),
   @w_ipAct                 Varchar(30),
   @w_prod_fin              Integer,
   @w_idEstatus             Integer,
   @w_operacion             Integer,
   @w_estatus               Integer,
   @w_mensaje               Varchar(250);

Begin

   Select @w_idRelacion          = idRelacion,
          @w_prod_id             = prod_id,
          @w_secuencia           = secuencia,
          @w_precioLista         = precioLista,
          @w_descuento           = descuento,
          @w_precioneto          = precioneto,
          @w_tasaIva             = tasaIva,
          @w_montoIva            = montoIva,
          @w_precioTotal         = precioTotal,
          @w_idEstatus           = idEstatus,
          @w_usuario             = usuario,
          @w_ipAct               = ipAct,
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
-- Validación del id Relación.
--

   Select Top 1 @w_estatus = idEstatus
   From   dbo.SO_RelUnidadProductoFinTbl With (Nolock)
   Where  idRelacion = @w_idRelacion
   And    BorradoLogico = 0;
   If @@Rowcount = 0
      Begin
         Select @w_estatus = 9064,
                @w_mensaje = dbo.Fn_Busca_MensajeError(@w_operacion, @w_estatus);

         Raiserror (@w_mensaje, 16, 1)
         Rollback Transaction
         Return
      End;

  If @w_estatus = 3
      Begin
         Select @w_estatus = 9065,
                @w_mensaje = dbo.Fn_Busca_MensajeError(@w_operacion, @w_estatus);

         Raiserror (@w_mensaje, 16, 1)
         Rollback Transaction
         Return
      End;


--
-- Validación del producto financiero
--

   If Not Exists ( Select Top 1 1
                   From   dbo.producto
                   Where  prod_id = @w_Prod_id)
     Begin
        Select @w_estatus = 8046,
               @w_mensaje = dbo.Fn_Busca_MensajeError(@w_operacion, @w_estatus)

         Raiserror (@w_mensaje, 16, 1)
         Rollback Transaction
         Return

      End

   Return
End
Go
