Use SisArrendaCredito
Go

--
-- Script: alta Estatus
--

Declare
   @w_tabla        Sysname,
   @w_columna      Sysname,
   @w_valor        Integer,
   @w_usuario      Varchar(20),
   @w_fechaAct     Datetime,
   @w_ipAct        Varchar(30);
Begin
   SET NOCOUNT ON;

   Select @w_tabla    = 'SO_RelUnidadProductoFinTbl',
          @w_columna  = 'idEstatus',
          @w_usuario  = 'WEBSET',
          @w_fechaAct = Getdate(),
          @w_ipAct    = dbo.Fn_BuscaDireccionIP();


   If Exists ( Select top 1 1 
               From   dbo.catGeneralesTbl
               Where  tabla   = @w_tabla
               And    columna = @w_columna)
      Begin
         Delete dbo.catGeneralesTbl
         Where  tabla   = @w_tabla
         And    columna = @w_columna;
     End;

    Insert Into dbo.catGeneralesTbl
    (tabla,   columna,  valor, descripcion,
     usuario, fechaAct, ipAct)
    Select @w_tabla,   @w_columna,  1, 'Solicitado',
           @w_usuario, @w_fechaAct, @w_ipAct
    Union
    Select @w_tabla,   @w_columna,  2, 'Autorizado',
           @w_usuario, @w_fechaAct, @w_ipAct
    Union
    Select @w_tabla,   @w_columna, 3, 'Procesado',
           @w_usuario, @w_fechaAct, @w_ipAct
    Union        
    Select @w_tabla,   @w_columna, 4, 'Rechazado',
           @w_usuario, @w_fechaAct, @w_ipAct
    Union   
    Select @w_tabla,   @w_columna, 5, 'Cancelado',
           @w_usuario, @w_fechaAct, @w_ipAct;


    Return

End
Go