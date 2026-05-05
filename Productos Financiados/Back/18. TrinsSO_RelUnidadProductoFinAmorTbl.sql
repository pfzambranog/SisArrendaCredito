--
-- Diparador:     TrinsSO_RelUnidadProductoFinAmorTbl
-- Objetivo:      Disparador de Alta y Update relacionado a la Entidad SO_RelUnidadProductoFinAmorTbl
-- Fecha:         04-may-2026
-- Version:       1
--
-- Programador:   Pedro Zambrano
--

Create Or Alter Trigger dbo.TrinsSO_RelUnidadProductoFinAmorTbl
On     dbo.SO_RelUnidadProductoFinAmorTbl
After  Insert, Update
As

Declare
   @w_idRelacion            Integer,
   @w_amortiz_id            Integer,
   @w_fecha                 Date,
   @w_registros             Integer,
   @w_noamort               Integer,
   @w_total                 Decimal(18, 2),
   @w_monto                 Decimal(18, 2),
   @w_capital               Decimal(18, 2),
   @w_idEstatus             Tinyint,
   @w_borradoLogico         Bit,
   @w_usuario               Varchar( 10),
   @w_operacion             Integer,
   @w_estatus               Integer,
   @w_mensaje               Varchar(250);

Begin

   Select @w_idRelacion          = idRelacion,
          @w_amortiz_id          = amortiz_id,
          @w_fecha               = fechaAmort,
          @w_capital             = capital,
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
-- Validación del id Relación.
--
   Select @w_idEstatus       = idEstatus,
          @w_borradoLogico   = @w_borradoLogico,
          @w_noamort         = noamort,
          @w_total           = totalFinaciamiento
   From   dbo.SO_RelUnidadProductoFinTbl With (Nolock)
   Where  idRelacion = @w_idRelacion
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


--

   Select @w_registros = Count(1),
          @w_monto     = Sum(capital)
   From   dbo.SO_RelUnidadProductoFinAmorTbl a With (Nolock)
   Where  idRelacion    = @w_idRelacion;

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
               From   dbo.SO_RelUnidadProductoFinAmorTbl
               Where  idRelacion    = @w_idRelacion
               And    @w_fecha      < fechaAmort)
      Begin
         Select @w_estatus = 9999,
                @w_mensaje = 'La fecha Seleccionada se Traslapa con una ya registrada';

         Raiserror (@w_mensaje, 16, 1)
         Rollback Transaction
         Return

      End


   Return
End
Go
