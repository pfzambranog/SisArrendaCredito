Use SisArrendaCredito
Go

/*

Declare
   @PnIdRelacion            Integer         = 2,
   @PnProd_id               Integer         = 26,
   @PnSecuencia             Integer         = 1,
   @PnPrecioLista           Decimal(18, 2)  = 120000,
   @PnDescuento             Decimal(18, 2)  = 10000,
   @PnPrecioneto            Decimal(18, 2)  = 110000,
   @PnTasaIva               Decimal(18, 4)  = 16.5,
   @PnMontoIva              Decimal(18, 2)  = 181.50,
   @PnPrecioTotal           Decimal(18, 2)  = 11181.50,
   @PnIdEstatus             Integer         = 1,
   @PsUsuario               Varchar( 10)    = 'ARRENDAN',
   @PsIpAct                 Varchar( 10)    = Null,
   @PnEstatus               Integer         = 0,
   @PsMensaje               Varchar( 250)   = Char(32);

Begin
   Execute dbo.spu_SO_RelUnidadProductoFinDetTbl @PnIdRelacion  = @PnIdRelacion,
                                                 @PnProd_id     = @PnProd_id,
                                                 @PnSecuencia   = @PnSecuencia,
                                                 @PnPrecioLista = @PnPrecioLista,
                                                 @PnDescuento   = @PnDescuento,
                                                 @PnPrecioneto  = @PnPrecioneto,
                                                 @PnTasaIva     = @PnTasaIva,
                                                 @PnMontoIva    = @PnMontoIva,
                                                 @PnPrecioTotal = @PnPrecioTotal,
                                                 @PnIdEstatus   = @PnIdEstatus,
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
-- Procedimiento: spu_SO_RelUnidadProductoFinDetTbl
-- Objetivo:      Procedimiento de Actualización a la Entidad spu_SO_RelUnidadProductoFinDetTbl
-- Fecha:         01-may-2026
-- Version:       1
--
-- Programador:   Pedro Zambrano
--

Create Or Alter Procedure dbo.spu_SO_RelUnidadProductoFinDetTbl
  (@PnIdRelacion            Integer,
   @PnProd_id               Integer,
   @PnSecuencia             Integer,
   @PnPrecioLista           Decimal(18, 2) = Null,
   @PnDescuento             Decimal(18, 2) = Null,
   @PnPrecioneto            Decimal(18, 2) = Null,
   @PnTasaIva               Decimal(18, 4) = Null,
   @PnMontoIva              Decimal(18, 2) = Null,
   @PnPrecioTotal           Decimal(18, 2) = Null,
   @PnIdEstatus             Integer        = Null,
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
   @w_sql                   Varchar(Max),
   @w_comilla               Char(1),
   @w_fecha                 Datetime;

Begin
   Set Nocount       On
   Set Xact_Abort    On
   Set Ansi_Nulls    Off

   Select @PnEstatus       = dbo.Fn_BuscaIdUsuario(@PsUsuario),
          @PsMensaje       = Char(32),
          @w_fecha         = Getdate(),
          @w_registros     = 0,
          @w_operacion     = 9999,
          @w_comilla       = Char(39),
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
          @w_borradoLogico   = borradoLogico
   From   dbo.SO_RelUnidadProductoFinDetTbl With (Nolock)
   Where  idRelacion = @PnIdRelacion
   And    prod_id    = @PnProd_id
   And    secuencia  = @PnSecuencia;
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

   Set @w_sql = Concat('Update dbo.SO_RelUnidadProductoFinDetTbl ',
                       'Set    ultActual  = ', @w_comilla, Cast(@w_fecha As Varchar), @w_comilla, ', ',
                              'usuario    = ', @w_comilla, @PsUsuario,                @w_comilla, ', ',
                              'ipAct      = ', @w_comilla, @PsIpAct,                  @w_comilla);

   If @PnPrecioLista Is Not Null
      Begin
         Set @w_sql = Concat(@w_sql, ', precioLista = ', @PnPrecioLista);
      End

   If @PnDescuento Is Not Null
      Begin
         Set @w_sql = Concat(@w_sql, ', descuento = ', @PnDescuento);
      End

   If @PnPrecioneto Is Not Null
      Begin
         Set @w_sql = Concat(@w_sql, ', precioneto = ', @PnPrecioneto);
      End

   If @PnTasaIva Is Not Null
      Begin
         Set @w_sql = Concat(@w_sql, ', tasaIva = ', @PnTasaIva);
      End

   If @PnMontoIva Is Not Null
      Begin
         Set @w_sql = Concat(@w_sql, ', montoIva = ', @PnMontoIva);
      End

   If @PnPrecioTotal Is Not Null
      Begin
         Set @w_sql = Concat(@w_sql, ', precioTotal = ', @PnPrecioTotal);
      End

   If @PnIdEstatus Is Not Null
      Begin
         Set @w_sql = Concat(@w_sql, ', idEstatus = ', @PnIdEstatus);
      End

   Set @w_sql = Concat(@w_sql, ' Where idRelacion = ', @PnIdRelacion, ' ',
                               ' And    prod_id    = ', @PnProd_id,   ' ',
                               ' And    secuencia  = ', @PnSecuencia);

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
      End;

Salida:

   Set Xact_Abort    Off
   Return
End
Go

Declare
   @w_valor          Nvarchar(250) = 'Procedimiento de Actualización a la Entidad SO_RelUnidadProductoFinDetTbl',
   @w_procedimiento  NVarchar(250) = 'spu_SO_RelUnidadProductoFinDetTbl';

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
