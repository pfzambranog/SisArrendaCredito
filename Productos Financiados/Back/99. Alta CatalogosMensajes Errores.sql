Use SisArrendaCredito
Go

--
-- Script: alta Mensajes Errores
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
               And    idError      Between 10011 And 10015)
      Begin
         Delete dbo.catMensajesErroresTbl
         Where  idFormulario = @w_idFormulario
         And    idError      Between 10011 And 10015;
     End;

   Insert Into dbo.catMensajesErroresTbl
  (idFormulario, idError, mensaje, idUsuarioAct,
   fechaAct,     ipAct)
   Select @w_idFormulario, @w_idError, 'El Código del Producto Finanaciero Seleccionado no es Válido', @w_usuario,
          @w_fecha,        @w_ipAct
   Union
   Select @w_idFormulario, @w_idError + 1, 'El Código del Producto Finanaciero Seleccionado ya Existe', @w_usuario,
          @w_fecha,        @w_ipAct
   Union
   Select @w_idFormulario, @w_idError + 2, 'El Código del Producto Finanaciero esta Deshabilitado', @w_usuario,
          @w_fecha,        @w_ipAct
   Union
   Select @w_idFormulario, @w_idError + 3, 'El Código del Producto Finanaciero no es de Arrendamiento', @w_usuario,
          @w_fecha,        @w_ipAct
   Union
   Select @w_idFormulario, @w_idError + 4, 'El Código del Producto Finanaciero no es Credito', @w_usuario,
          @w_fecha,        @w_ipAct;

   Set @w_idError       = 9061

   If Exists ( Select top 1 1
               From   dbo.catMensajesErroresTbl
               Where  idFormulario = @w_idFormulario
               And    idError      Between @w_idError And 9063)
      Begin
         Delete dbo.catMensajesErroresTbl
         Where  idFormulario = @w_idFormulario
         And    idError      Between @w_idError And 9063;
     End;

   Insert Into dbo.catMensajesErroresTbl
  (idFormulario, idError, mensaje, idUsuarioAct,
   fechaAct,     ipAct)
   Select @w_idFormulario, @w_idError, 'El Código de usuario seleccionado para autorizar no es Válido', @w_usuario,
          @w_fecha,        @w_ipAct
   Union
   Select @w_idFormulario, @w_idError + 1, 'El Código de usuario seleccionado para autorizar no esta Habilitado', @w_usuario,
          @w_fecha,        @w_ipAct
   Union
   Select @w_idFormulario, @w_idError + 2, 'La Fecha de Autorizacion no es Valida', @w_usuario,
          @w_fecha,        @w_ipAct
  Return

End
Go