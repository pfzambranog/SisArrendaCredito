Use SisArrendaCredito
Go

/*

Declare
   @PnIdRelacion            Integer        = 2,
   @PnProd_id               Integer        = 26,
   @PnPrecioLista           Decimal(18, 2) = 110000,
   @PnDescuento             Decimal(18, 2) = 0,
   @PnPrecioneto            Decimal(18, 2) = 110000,
   @PnTasaIva               Decimal(18, 4) = 16.5,
   @PnMontoIva              Decimal(18, 2) = 181.50,
   @PnPrecioTotal           Decimal(18, 2)  = 11181.50,
   @PsUsuario               Varchar( 10)    = 'ARRENDAN',
   @PsIpAct                 Varchar( 10)    = Null,
   @PnEstatus               Integer         = 0,
   @PsMensaje               Varchar( 250)   = Char(32);

Begin
   Execute dbo.spa_SO_RelUnidadProductoFinDetTbl @PnIdRelacion  = @PnIdRelacion,
                                                 @PnProd_id     = @PnProd_id,
                                                 @PnPrecioLista = @PnPrecioLista,
                                                 @PnDescuento   = @PnDescuento,
                                                 @PnPrecioneto  = @PnPrecioneto,
                                                 @PnTasaIva     = @PnTasaIva,
                                                 @PnMontoIva    = @PnMontoIva,
                                                 @PnPrecioTotal = @PnPrecioTotal,
                                                 @PsUsuario     = @PsUsuario,
                                                 @PsIpAct       = @PsIpAct,
                                                 @PnEstatus     = @PnEstatus Output,
                                                 @PsMensaje     = @PsMensaje Output;

   Select @PnEstatus error, @PsMensaje Mensaje;
   Return;

End;
Go

*/

--
-- Procedimiento: spa_SO_RelUnidadProductoFinDetTbl
-- Objetivo:      Procedimiento de Alta a la Entidad SO_RelUnidadProductoFinTbl
-- Fecha:         01-may-2026
-- Version:       1
--
-- Programador:   Pedro Zambrano
--

Create Or ALter Procedure dbo.spa_SO_RelUnidadProductoFinDetTbl
  (@PnIdRelacion            Integer,
   @PnProd_id               Integer,
   @PnPrecioLista           Decimal(18, 2),
   @PnDescuento             Decimal(18, 2) = 0,
   @PnPrecioneto            Decimal(18, 2),
   @PnTasaIva               Decimal(18, 4) = 0,
   @PnMontoIva              Decimal(18, 2),
   @PnPrecioTotal           Decimal(18, 2),
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
   @w_secuencia             Integer,
   @w_borradoLogico         Integer,
   @w_idEstatus             Integer,
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

   Select @w_idEstatus       = idEstatus,
          @w_borradoLogico   = @w_borradoLogico
   From   dbo.SO_RelUnidadProductoFinTbl With (Nolock)
   Where  idRelacion = @PnIdRelacion
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

   If Not Exists ( Select Top 1 1
                   From   dbo.producto
                   Where  prod_id = @PnProd_id)
     Begin
        Select @PnEstatus = 8046,
                @PsMensaje = dbo.Fn_Busca_MensajeError(@w_operacion, @PnEstatus)

         Goto Salida;

      End

   Select Top 1 @w_idEstatus = idEstatus
   From   dbo.SO_RelUnidadProductoFinDetTbl a With (Nolock)
   Where  idRelacion    = @PnIdRelacion
   And    prod_id       = @PnProd_id
   And    idEstatus     = 1
   And    BorradoLogico = 0;
   If @@Rowcount = 0
      Begin
         Set @w_idEstatus = 0;
      End

   If @w_idEstatus = 1
      Begin
         Select @PnEstatus = 9069,
                @PsMensaje = dbo.Fn_Busca_MensajeError(@w_operacion, @PnEstatus)

         Goto Salida;

      End        

   Select @w_secuencia = Max(secuencia)
   From   dbo.SO_RelUnidadProductoFinDetTbl a With (Nolock)
   Where  idRelacion = @PnIdRelacion
   And    prod_id    = @PnProd_id;     
   Set @w_secuencia = Isnull(@w_secuencia, 0) + 1
       
   Begin Try
      Insert Into dbo.SO_RelUnidadProductoFinDetTbl
     (idRelacion,  prod_id,    secuencia, precioLista,
      descuento,   precioneto, tasaIva,   montoIva,
      precioTotal, usuario,    ipAct)
      Select @PnIdRelacion,  @PnProd_id,    @w_secuencia, @PnPrecioLista,
             @PnDescuento,   @PnPrecioneto, @PnTasaIva,   @PnMontoIva,
             @PnPrecioTotal, @PsUsuario,    @PsIpAct;
      Set @PsMensaje = @@Identity;

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
   @w_valor          Nvarchar(250) = 'Procedimiento de Alta a la Entidad SO_RelUnidadProductoFinDetTbl',
   @w_procedimiento  NVarchar(250) = 'spa_SO_RelUnidadProductoFinDetTbl';

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