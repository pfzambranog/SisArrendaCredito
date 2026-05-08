Use SisArrendaCredito
Go

/*

Declare
   @PnId_Unidad             Integer         = 106990,
   @PnProd_Id               Integer         = 18,
   @PnMontoFinanciar        Decimal(18, 2)  = 120,
   @PnNoamort               Integer         = 12,
   @PnTasaFinanciamiento    Decimal(18, 4)  = 10,
   @PnTotalIntereses        Decimal(18, 2)  = 12,
   @PnIdEstatus             Integer         = 1,
   @PsUsuario               Varchar( 10)    = 'ARRENDAN',
   @PsIpAct                 Varchar( 10)    = Null,
   @PnEstatus               Integer         = 0,
   @PsMensaje               Varchar( 250)   = Null;

Begin
   Execute dbo.spa_SO_RelUnidadProductoFinTbl @PnId_Unidad           = @PnId_Unidad,
                                              @PnProd_Id             = @PnProd_Id,
                                              @PnMontoFinanciar      = @PnMontoFinanciar,
                                              @PnNoamort             = @PnNoamort,
                                              @PnTasaFinanciamiento  = @PnTasaFinanciamiento,
                                              @PnTotalIntereses      = @PnTotalIntereses,
                                              @PnIdEstatus           = @PnIdEstatus,
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
-- Fecha:         07-May-2026
-- Version:       2
--
-- Programador:   Pedro Zambrano
--

Create Or ALter Procedure dbo.spa_SO_RelUnidadProductoFinTbl
  (@PnId_Unidad             Integer,
   @PnProd_Id               Integer,
   @PnMontoFinanciar        Decimal(18, 2),
   @PnNoamort               Integer,
   @PnTasaFinanciamiento    Decimal(18, 4),
   @PnTotalIntereses        Decimal(18, 2)  = 0,
   @PnIdEstatus             Integer         = 1,
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
   @w_plazo                 Integer,
   @w_Contrato_ERP          Integer,
   @w_FE_nprod              Integer,
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

   If Exists ( Select Top 1 1
               From   dbo.SO_RelUnidadProductoFinTbl With (Nolock)
               Where  id_unidad = @PnId_Unidad
               And    prod_id   = @PnProd_Id)
      Begin
         Select @PnEstatus = 9069,
                @PsMensaje = 'Error.: ' + (dbo.Fn_Busca_MensajeError(@w_operacion, @PnEstatus))

         Goto Salida;
      End

   If Exists ( Select Top 1 1
               From   dbo.SO_RelUnidadProductoFinTbl With (Nolock)
               Where  id_unidad = @PnId_Unidad
               And    idEstatus = 3)
      If @@Rowcount > 0
      Begin
         Select @PnEstatus = 9065,
                @PsMensaje = 'Error.: ' + (dbo.Fn_Busca_MensajeError(@w_operacion, @PnEstatus))

         Goto Salida;
      End

--
-- Validación de la Unidad y el producto Financiero.
--

   Select Top 1 @w_prod_fin     = c.prod_fin_id,
                @w_plazo        = d.numeroPlazo,
                @w_Contrato_ERP = b.Contrato_ERP
   From   dbo.SO_SolCotizacion a With (Nolock)
   Join   dbo.SO_Unidades b      With (Nolock)
   On     b.idSolicitud = a.idSolicitud
   Join   dbo.so_tipos c         With (Nolock)
   On     c.IdTipo      = a.IdTipo
   Join   SO_SolCondiciones_art d With (NOLOCK)
   On     d.IdArticulo  = b.Id_articulo
   Where  b.Id_Unidad   = @PnId_Unidad;
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

   If @w_Contrato_ERP Is Not Null
       Begin
          Select @PnEstatus = 10016,
                 @PsMensaje = dbo.Fn_Busca_MensajeError(@w_operacion, @PnEstatus);

         Goto Salida;
      End

   If @PnNoamort > @w_plazo
       Begin
          Select @PnEstatus = 9067,
                 @PsMensaje = dbo.Fn_Busca_MensajeError(@w_operacion, @PnEstatus);

         Goto Salida;
      End

--
-- Validación del Producto a Financiar.
--

   Select @w_FE_nprod = Isnull(FE_nprod, 0)
   From   dbo.Producto  With (Nolock)
   Where  prod_id       = @PnProd_Id
   And    borradoLogico = 0;
   If @@Rowcount = 0
      Begin
         Select @PnEstatus = 10011,
                @PsMensaje = dbo.Fn_Busca_MensajeError(@w_operacion, @PnEstatus);

         Goto Salida;
      End

   If @w_FE_nprod != 1
      Begin
         Select @PnEstatus = 10013,
                @PsMensaje = dbo.Fn_Busca_MensajeError(@w_operacion, @PnEstatus);

         Goto Salida;
      End

   Begin Try
      Insert Into dbo.SO_RelUnidadProductoFinTbl
     (Id_Unidad,          prod_id,         montoFinanciar, noamort,
      tasaFinanciamiento, totalIntereses,  idEstatus,      usuario,
      ipAct)
      Select @PnId_Unidad,           @PnProd_Id,        @PnMontoFinanciar,  @PnNoamort,
             @PnTasaFinanciamiento,  @PnTotalIntereses, @PnIdEstatus,       @PsUsuario,
             @PsIpAct;
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
