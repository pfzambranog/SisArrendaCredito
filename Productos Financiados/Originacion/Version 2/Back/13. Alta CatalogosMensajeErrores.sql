Use SisArrendaCredito
Go

--
-- Script:      Alta de los Mensajes Errores relacionados al proceso de Financiamiento de Productos
-- Fecha:       07-May-2026
-- Versión:     2
-- Programador: Pedro Zambrano
--


Declare
   @w_idFormulario    Integer,
   @w_idError         Integer,
   @w_usuario         Integer,
   @w_fecha           Datetime,
   @w_ipAct           Varchar(30);

Begin
   Set Nocount        On;

   Select @w_usuario       = 42,
          @w_fecha         = Getdate(),
          @w_idFormulario  = 9999,
          @w_idError       = 10011,
          @w_ipAct         = dbo.Fn_BuscaDireccionIP();


   If Exists ( Select top 1 1
               From   dbo.catMensajesErroresTbl
               Where  idFormulario = @w_idFormulario
               And    idError      Between 10011 And 10016)
      Begin
         Delete dbo.catMensajesErroresTbl
         Where  idFormulario = @w_idFormulario
         And    idError      Between 10011 And 10016;
     End;

   Insert Into dbo.catMensajesErroresTbl
  (idFormulario, idError, mensaje, idUsuarioAct,
   fechaAct,     ipAct)
   Select @w_idFormulario, @w_idError,     'El Código del Producto a Finanaciar Seleccionado no es Válido', @w_usuario,
          @w_fecha,        @w_ipAct
   Union
   Select @w_idFormulario, @w_idError + 1, 'El Código del Producto a Finanaciar Seleccionado ya Existe', @w_usuario,
          @w_fecha,        @w_ipAct
   Union
   Select @w_idFormulario, @w_idError + 2, 'El Código del Producto a Finanaciar no está habilitado para Financiamiento', @w_usuario,
          @w_fecha,        @w_ipAct
   Union
   Select @w_idFormulario, @w_idError + 3, 'El Código del Producto a Finanaciar no es de Arrendamiento', @w_usuario,
          @w_fecha,        @w_ipAct
   Union
   Select @w_idFormulario, @w_idError + 4, 'El Código del Producto a Finanaciar no es Crédito', @w_usuario,
          @w_fecha,        @w_ipAct
   Union
   Select @w_idFormulario, @w_idError + 5, 'El Código del Producto ya Fue Activado en Cartera', @w_usuario,
          @w_fecha,        @w_ipAct;

   Set @w_idError       = 9061

   If Exists ( Select top 1 1
               From   dbo.catMensajesErroresTbl
               Where  idFormulario       = @w_idFormulario
               And    idError      Between @w_idError And @w_idError + 15)
      Begin
         Delete dbo.catMensajesErroresTbl
         Where  idFormulario       = @w_idFormulario
         And    idError      Between @w_idError And @w_idError + 15;
     End;

   Insert Into dbo.catMensajesErroresTbl
  (idFormulario, idError, mensaje, idUsuarioAct,
   fechaAct,     ipAct)
   Select @w_idFormulario, @w_idError,     'El Código de usuario seleccionado para autorizar no es Válido', @w_usuario,
          @w_fecha,        @w_ipAct
   Union
   Select @w_idFormulario, @w_idError + 1, 'El Código de usuario seleccionado para autorizar no esta Habilitado', @w_usuario,
          @w_fecha,        @w_ipAct
   Union
   Select @w_idFormulario, @w_idError + 2, 'La Fecha de Autorizacion no es Valida', @w_usuario,
          @w_fecha,        @w_ipAct
   Union
   Select @w_idFormulario, @w_idError + 3, 'La Relacion Unidad-Producto a financiar no Existe', @w_usuario,
          @w_fecha,        @w_ipAct
   Union
   Select @w_idFormulario, @w_idError + 4, 'La Relacion Unidad-Producto a financiar ya fue procesado', @w_usuario,
          @w_fecha,        @w_ipAct
   Union
   Select @w_idFormulario, @w_idError + 5, 'No Existen Registros para los Parámetros Seleccionados', @w_usuario,
          @w_fecha,        @w_ipAct
   Union
   Select @w_idFormulario, @w_idError + 6, 'El Número de cuotas de los productos financiados es mayor a la de la Unidad.', @w_usuario,
          @w_fecha,        @w_ipAct
   Union
   Select @w_idFormulario, @w_idError + 7, 'La Relacion Unidad-Producto a financiar esta Borrado Logicamente.', @w_usuario,
          @w_fecha,        @w_ipAct
   Union
   Select @w_idFormulario, @w_idError + 8, 'La Relacion Unidad-Producto a financiar ya Existe.', @w_usuario,
          @w_fecha,        @w_ipAct
   Union
   Select @w_idFormulario, @w_idError + 9, 'El Número de Amotizaciones supera el número de cuotas.', @w_usuario,
          @w_fecha,        @w_ipAct
          Union
   Select @w_idFormulario, @w_idError + 10, 'La suma de las Amotizaciones supera el importe a financiar.', @w_usuario,
          @w_fecha,        @w_ipAct
   Union
   Select @w_idFormulario, @w_idError + 11, 'La Amotizacion a financiar ya Existe.', @w_usuario,
          @w_fecha,        @w_ipAct
   Union
   Select @w_idFormulario, @w_idError + 12, 'La Amotizacion NO es Válida.', @w_usuario,
          @w_fecha,        @w_ipAct
   Union
   Select @w_idFormulario, @w_idError + 13, 'La Relación Producto - Unidad No esta disponible Para su Actualización.', @w_usuario,
          @w_fecha,        @w_ipAct
   Union
   Select @w_idFormulario, @w_idError + 14, 'La fecha de Amortización Seleccionada se Traslapa con una ya registrada', @w_usuario,
          @w_fecha,        @w_ipAct
   Union
   Select @w_idFormulario, @w_idError + 15, 'El Monto del IVA no Puede ser Mayor a los Intereses', @w_usuario,
          @w_fecha,        @w_ipAct;

  Return

End
Go
