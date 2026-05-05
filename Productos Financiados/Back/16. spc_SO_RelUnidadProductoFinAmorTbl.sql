Use SisArrendaCredito
Go

/*

Declare
   @PnIdRelacion            Integer         = 2,
   @PnAmortiz_id            Integer         = Null,
   @PdFechaAmort            Date            = Null,
   @PnIdEstatus             Integer         = Null,
   @PsUsuario               Varchar( 10)    = 'ARRENDAN',
   @PnEstatus               Integer         = 0,
   @PsMensaje               Varchar( 250)   = Char(32);

Begin
   Execute dbo.Spc_SO_RelUnidadProductoFinAmorTbl @PnIdRelacion  = @PnIdRelacion,
                                                  @PnAmortiz_id  = @PnAmortiz_id,
                                                  @PdFechaAmort  = @PdFechaAmort,
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
-- Procedimiento: Spc_SO_RelUnidadProductoFinAmorTbl
-- Objetivo:      Procedimiento de Consulta a la Entidad SO_RelUnidadProductoFinAmorTbl
-- Fecha:         04-may-2026
-- Version:       1
--
-- Programador:   Pedro Zambrano
--

Create Or Alter Procedure dbo.Spc_SO_RelUnidadProductoFinAmorTbl
  (@PnIdRelacion            Integer         = Null, 
   @PnAmortiz_id            Integer         = Null,
   @PdFechaAmort            Date            = Null,
   @PnIdEstatus             Tinyint         = Null,
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
   @w_comilla               Char(1);

Begin
   Set Nocount       On
   Set Xact_Abort    On
   Set Ansi_Nulls    Off

   Select @PnEstatus       = dbo.Fn_BuscaIdUsuario(@PsUsuario),
          @PsMensaje       = Char(32),
          @w_registros     = 0,
          @w_operacion     = 9999,
          @w_comilla       = Char(39),
          @PsIpAct         = Isnull(@PsIpAct, dbo.Fn_BuscaDireccionIP());

  If @PnEstatus != 0
     Begin
        If @PnEstatus Between 9998 And 9999
           Begin
              Set @PsMensaje = dbo.Fn_Busca_MensajeError(@w_operacion, @PnEstatus);
              Goto Salida;
           End;
     End;

   Set @PnEstatus = 0

   Set @w_sql = Concat('Select a.idRelacion, b.Id_Unidad unidad, a.amortiz_id amortizacion, ',
                              'Convert(Char(10), fechaAmort, 103) fechaAmortizacion, ',
                              'capital AmortizaCapital, intereses AmortizaInteres, ',
                              'gastos, seguros, a.idEstatus Estatus, ',
                              'Iif(a.idEstatus = 1, ', @w_comilla, 'Pendiente Activacion', @w_comilla, ', ', @w_comilla, 'Activado', @w_comilla, ') EstatusAmortizacion, ',
                               'Convert(Char(10), a.ultActual, 103) UltfechaActualizacion, '                           ,
                               'a.usuario, dbo.Fn_BuscaNombreUsuarioSIAN(dbo.Fn_BuscaIdUsuario(a.usuario)) actualizo, ',
                               'a.ipAct ',
                        'From   dbo.SO_RelUnidadProductoFinAmorTbl  a With (Nolock) ',
                        'Join   dbo.SO_RelUnidadProductoFinTbl      b With (Nolock) ',
                        'On     b.idRelacion   = a.idRelacion '                     ,
                        'Where  b.borradoLogico = 0');

   If @PnIdRelacion Is Not Null
      Begin
         Set @w_sql = Concat(@w_sql, ' And a.idRelacion = ', @PnIdRelacion);
      End


   If @PnAmortiz_id Is Not Null
      Begin
         Set @w_sql = Concat(@w_sql, ' And a.amortiz_id = ', @PnAmortiz_id);
      End


   If @PdFechaAmort Is Not Null
      Begin
         Set @w_sql = Concat(@w_sql, ' And a.fechaAmort = ', @w_comilla, Cast(@PdFechaAmort As Varchar), @w_Comilla);
      End


   If @PnIdEstatus Is Not Null
      Begin
         Set @w_sql = Concat(@w_sql, ' And a.idEstatus = ', @PnIdEstatus);
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
   @w_valor          Nvarchar(250) = 'Procedimiento de Consulta a la Entidad SO_RelUnidadProductoFinAmorTbl',
   @w_procedimiento  NVarchar(250) = 'Spc_SO_RelUnidadProductoFinAmorTbl';

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
