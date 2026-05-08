Use SisArrendaCredito
Go

/*

Declare
   @PnIdRelacion            Integer         = 2,
   @PnIdEstatus             Integer         = Null,
   @PsUsuario               Varchar( 10)    = 'ARRENDAN',
   @PnEstatus               Integer         = 0,
   @PsMensaje               Varchar( 250)   = Char(32);

Begin
   Execute dbo.spc_SO_RelUnidadProductoFinDetTbl @PnIdRelacion  = @PnIdRelacion,
                                                 @PnIdEstatus   = @PnIdEstatus,
                                                 @PsUsuario     = @PsUsuario,
                                                 @PnEstatus     = @PnEstatus Output,
                                                 @PsMensaje     = @PsMensaje Output;

   Select @PnEstatus error, @PsMensaje Mensaje;
   Return;

End;
Go

*/

--
-- Procedimiento: spc_SO_RelUnidadProductoFinDetTbl
-- Objetivo:      Procedimiento de Consulta a la Entidad SO_RelUnidadProductoFinDetTbl
-- Fecha:         01-may-2026
-- Version:       1
--
-- Programador:   Pedro Zambrano
--

Create Or Alter Procedure dbo.spc_SO_RelUnidadProductoFinDetTbl
  (@PnIdRelacion            Integer        = Null,
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

   Set @w_sql = Concat('Select  a.idRelacion, b.Id_Unidad,   a.prod_id,   c.desc_completa producto,  ',
                               'a.secuencia,  a.precioLista, a.descuento, a.precioneto,   a.tasaIva, ',
                               'a.montoIva,   a.precioTotal, a.idEstatus, d.descripcion   estatus,   ',
                               'Convert(Char(10), a.fechaAlta, 103) fechaAlta, '                      ,
                               'Convert(Char(10), a.ultActual, 103) UltfechaActualizacion, '          ,
                               'a.usuario, dbo.Fn_BuscaNombreUsuarioSIAN(dbo.Fn_BuscaIdUsuario(a.usuario)) actualizo, ',
                               'a.ipAct ',
                        'From   dbo.SO_RelUnidadProductoFinDetTbl a With (Nolock) ',
                        'Join   dbo.SO_RelUnidadProductoFinTbl    b With (Nolock) ',
                        'On     b.idRelacion    = a.idRelacion '                   ,
                        'Join   dbo.producto                      c With (Nolock) ',
                        'On     c.prod_id       = a.prod_id '                      ,
                        'Join   dbo.catCriteriosTbl               d With (Nolock) ',
                        'On     d.criterio      = ', @w_comilla , 'idEstatus', @w_comilla, ' ',
                        'And    d.valor         = a.idEstatus ',
                        'Where  a.borradoLogico = 0');

   If @PnIdRelacion Is Not Null
      Begin
         Set @w_sql = Concat(@w_sql, ' And a.idRelacion = ', @PnIdRelacion);
      End

   If @PnIdEstatus Is Not Null
      Begin
         Set @w_sql = Concat(@w_sql, ', idEstatus = ', @PnIdEstatus);
      End


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
   @w_valor          Nvarchar(250) = 'Procedimiento de Consulta a la Entidad SO_RelUnidadProductoFinDetTbl',
   @w_procedimiento  NVarchar(250) = 'spc_SO_RelUnidadProductoFinDetTbl';

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
