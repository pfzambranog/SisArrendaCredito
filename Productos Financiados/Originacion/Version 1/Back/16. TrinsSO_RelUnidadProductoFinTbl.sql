--
-- Diparador:     TrinsSO_RelUnidadProductoFinTbl
-- Objetivo:      Disparador de Alta y Update relacionado a la Entidad SO_RelUnidadProductoFinTbl
-- Fecha:         01-may-2026
-- Version:       1
--
-- Programador:   Pedro Zambrano
--

Create Or Alter Trigger dbo.TrinsSO_RelUnidadProductoFinTbl
On     dbo.SO_RelUnidadProductoFinTbl
After  Insert, Update
As

Declare
   @w_idRelacion            Integer,
   @w_Id_Unidad             Integer,
   @w_totalFinanciamiento   Decimal(18, 2),
   @w_noamort               Integer,
   @w_plazo                 Integer,
   @w_tasaFinanciamiento    Decimal(18, 4),
   @w_idEstatus             Integer,
   @w_usuarioAutoriza       Varchar(10),
   @w_fechaAutoriza         Datetime,
   @w_usuario               Varchar(10),
   @w_ipAct                 Varchar(30),
   @w_prod_fin              Integer,
   @w_operacion             Integer,
   @w_estatus               Integer,
   @w_mensaje               Varchar(250);

Begin

   Select @w_idRelacion          = idRelacion,
          @w_Id_Unidad           = Id_Unidad,
          @w_totalFinanciamiento = totalFinanciamiento,
          @w_noamort             = noamort,
          @w_plazo               = 0,
          @w_tasaFinanciamiento  = tasaFinanciamiento,
          @w_idEstatus           = idEstatus,
          @w_usuarioAutoriza     = usuarioAutoriza,
          @w_fechaAutoriza       = fechaAutoriza,
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

   If @w_UsuarioAutoriza Is Not Null Or
      @w_idEstatus       = 2
      Begin
         Set @w_estatus       = dbo.Fn_BuscaIdUsuario(@w_UsuarioAutoriza);

         If @w_estatus Between 9998 And 9999
            Begin
               If @w_estatus = 999
                  Begin
                     Set @w_estatus = 9061
                  End
               Else
                  Begin
                     Set @w_estatus = 9062
                  End

               Set @w_mensaje = dbo.Fn_Busca_MensajeError(@w_operacion, @w_estatus)
               Raiserror (@w_mensaje, 16, 1)
               Rollback Transaction
               Return
           End;


         If @w_FechaAutoriza Is Null
            Begin
               Select @w_estatus = 9063,
                      @w_mensaje = dbo.Fn_Busca_MensajeError(@w_operacion, @w_estatus);

               Raiserror (@w_mensaje, 16, 1)
               Rollback Transaction
               Return
            End;

      End;

--
-- Validación del identificador del estatus
--

   If @w_idEstatus Is Not Null
      Begin
         If Not Exists (Select Top 1 1
                        From   dbo.catGeneralesTbl  With (Nolock)
                        Where  tabla   = 'SO_RelUnidadProductoFinTbl'
                        And    columna = 'idEstatus'
                        And    Valor   = @w_idEstatus)
            Begin
               Select @w_estatus = 8033,
                      @w_mensaje = dbo.Fn_Busca_MensajeError(@w_operacion, @w_estatus);

               Raiserror (@w_mensaje, 16, 1)
               Rollback Transaction
               Return

            End;
      End;

   Set @w_estatus = 0

--
-- Validación de la Unidad y el producto Financiero.
--

   If @w_id_Unidad Is Not Null
      Begin
         Select Top 1 @w_prod_fin = c.prod_fin_id,
                      @w_plazo    = d.numeroPlazo
         From   dbo.SO_SolCotizacion a With (Nolock)
         Join   dbo.SO_Unidades b      With (Nolock)
         On     b.idSolicitud = a.idSolicitud
         Join   dbo.so_tipos c         With (Nolock)
         On     c.IdTipo      = a.IdTipo
         Join   SO_SolCondiciones_art d With (NOLOCK)
         On     d.IdArticulo = b.Id_articulo
         Where  b.Id_Unidad  = @w_Id_Unidad;
         If @@Rowcount =  0
            Begin
               Select @w_estatus = 6014,
                      @w_mensaje = dbo.Fn_Busca_MensajeError(@w_operacion, @w_estatus);

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

      End

   If @w_noamort > @w_plazo
      Begin
         Select @w_estatus = 9067,
                @w_mensaje = dbo.Fn_Busca_MensajeError(@w_operacion, @w_estatus);

         Raiserror (@w_mensaje, 16, 1)
         Rollback Transaction
         Return
      End

   Return
End
Go
