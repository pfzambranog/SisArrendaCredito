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
          @w_idError       = 10017,
          @w_ipAct         = dbo.Fn_BuscaDireccionIP();


   If Exists ( Select top 1 1
               From   dbo.catMensajesErroresTbl
               Where  idFormulario       = @w_idFormulario
               And    idError      Between @w_idError And @w_idError + 2)
      Begin
         Delete dbo.catMensajesErroresTbl
         Where  idFormulario       = @w_idFormulario
         And    idError      Between @w_idError And @w_idError + 2;
     End;

   Insert Into dbo.catMensajesErroresTbl
  (idFormulario, idError, mensaje, idUsuarioAct,
   fechaAct,     ipAct)
   Select @w_idFormulario, @w_idError,     'Error.: No existe parámetro de renta mínima hibrida', @w_usuario,
          @w_fecha,        @w_ipAct
   Union
   Select @w_idFormulario, @w_idError + 1, 'Error.: No existe parámetro de renta mínima Gas', @w_usuario,
          @w_fecha,        @w_ipAct
   Union
   Select @w_idFormulario, @w_idError + 2, 'Error.: La Tasa del IVA no está Declarada', @w_usuario,
          @w_fecha,        @w_ipAct;

  Return

End
Go
