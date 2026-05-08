Use SisArrendaCredito
Go

--
-- Tabla:       SO_AmortizacionUnidadProductoTbl
--              Tabla de Amortización de Productos Relacionados al Producto
-- Modulo:      Originación
-- Fecha:       04-May-2026
-- Versión:     2
-- Programador: Pedro Zambrano
--

If Exists (Select Top 1 1
           From   SysObjects
           Where  Uid = 1
           And    Type = 'U'
           And    Name = 'SO_AmortizacionUnidadProductoTbl')
   Begin
      Drop Table dbo.SO_AmortizacionUnidadProductoTbl
   End
Go

Create Table dbo.SO_AmortizacionUnidadProductoTbl
  (Id_Unidad             Integer        Not Null,
   prod_id               Integer        Not Null,
   amortiz_id            Integer        Not Null,
   fechaAmort            Date           Not Null,
   saldoCapital          Decimal(18, 2) Not Null,
   capital               Decimal(18, 2) Not Null,
   intereses             Decimal(18, 2) Not Null,
   iva                   Decimal(18, 2) Not Null,
   idEstatus             Tinyint        Not Null Default 1,
   ultActual             Datetime       Not Null Default Getdate(),
   usuario               Varchar(10)    Not Null,
   ipAct                 Varchar(30)        Null,
   Constraint SO_AmortizacionUnidadProductoPk
   Primary Key (Id_Unidad, prod_id, amortiz_id),
   Constraint SO_AmortizacionUnidadProductoFk01
   Foreign Key (Id_Unidad, prod_id)
   References dbo.SO_RelUnidadProductoFinTbl(Id_Unidad, prod_id) on Delete Cascade,
   Constraint SO_AmortizacionUnidadProductoCk01
   Check(idEstatus Between 1 And 2))
   On [Primary]
Go

--
-- Comentarios
--

Execute sp_addextendedproperty    @name       = 'MS_Description',
                                  @value      = 'Tabla de Amortización de los productos a financiar relacionados a una Unidad.',
                                  @level0type = 'Schema',
                                  @level0name = 'dbo',
                                  @level1type = 'Table',
                                  @level1name = 'SO_AmortizacionUnidadProductoTbl'
Go

Execute sp_addextendedproperty    @name       = 'MS_Description',
                                  @value      = 'Identificador Unico de la Unidad a la cual se le va a relaciones los productos a financiar.',
                                  @level0type = 'Schema',
                                  @level0name = 'dbo',
                                  @level1type = 'Table',
                                  @level1name = 'SO_AmortizacionUnidadProductoTbl',
                                  @level2type = 'Column',
                                  @level2name = 'Id_Unidad'
Go

Execute sp_addextendedproperty    @name       = 'MS_Description',
                                  @value      = 'Numero de Amortización.',
                                  @level0type = 'Schema',
                                  @level0name = 'dbo',
                                  @level1type = 'Table',
                                  @level1name = 'SO_AmortizacionUnidadProductoTbl',
                                  @level2type = 'Column',
                                  @level2name = 'amortiz_id'
Go

Execute sp_addextendedproperty    @name       = 'MS_Description',
                                  @value      = 'Fecha de la Amortización.',
                                  @level0type = 'Schema',
                                  @level0name = 'dbo',
                                  @level1type = 'Table',
                                  @level1name = 'SO_AmortizacionUnidadProductoTbl',
                                  @level2type = 'Column',
                                  @level2name = 'fechaAmort'
Go

Execute sp_addextendedproperty    @name       = 'MS_Description',
                                  @value      = 'Saldo del Capital a la fecha de Amortización.',
                                  @level0type = 'Schema',
                                  @level0name = 'dbo',
                                  @level1type = 'Table',
                                  @level1name = 'SO_AmortizacionUnidadProductoTbl',
                                  @level2type = 'Column',
                                  @level2name = 'saldoCapital'
Go

Execute sp_addextendedproperty    @name       = 'MS_Description',
                                  @value      = 'Monto del capital relacionada a la Amortización.',
                                  @level0type = 'Schema',
                                  @level0name = 'dbo',
                                  @level1type = 'Table',
                                  @level1name = 'SO_AmortizacionUnidadProductoTbl',
                                  @level2type = 'Column',
                                  @level2name = 'capital'
Go


Execute sp_addextendedproperty    @name       = 'MS_Description',
                                  @value      = 'Monto del Interes relacionado a la Amortización.',
                                  @level0type = 'Schema',
                                  @level0name = 'dbo',
                                  @level1type = 'Table',
                                  @level1name = 'SO_AmortizacionUnidadProductoTbl',
                                  @level2type = 'Column',
                                  @level2name = 'intereses'
Go

Execute sp_addextendedproperty    @name       = 'MS_Description',
                                  @value      = 'Importe del Iva de los Intereses.',
                                  @level0type = 'Schema',
                                  @level0name = 'dbo',
                                  @level1type = 'Table',
                                  @level1name = 'SO_AmortizacionUnidadProductoTbl',
                                  @level2type = 'Column',
                                  @level2name = 'Iva'
Go

Execute sp_addextendedproperty    @name       = 'MS_Description',
                                  @value      = 'Identificador del Estatus de la cuota. 1 = Pendiente, 2 = Procesada',
                                  @level0type = 'Schema',
                                  @level0name = 'dbo',
                                  @level1type = 'Table',
                                  @level1name = 'SO_AmortizacionUnidadProductoTbl',
                                  @level2type = 'Column',
                                  @level2name = 'idEstatus'
Go

Execute sp_addextendedproperty    @name       = 'MS_Description',
                                  @value      = 'Ultima Fecha de actualizacion del registro',
                                  @level0type = 'Schema',
                                  @level0name = 'dbo',
                                  @level1type = 'Table',
                                  @level1name = 'SO_AmortizacionUnidadProductoTbl',
                                  @level2type = 'Column',
                                  @level2name = 'ultActual'
Go

Execute sp_addextendedproperty    @name       = 'MS_Description',
                                  @value      = 'Ultima Usuario que realiza la actualizacion del registro',
                                  @level0type = 'Schema',
                                  @level0name = 'dbo',
                                  @level1type = 'Table',
                                  @level1name = 'SO_AmortizacionUnidadProductoTbl',
                                  @level2type = 'Column',
                                  @level2name = 'usuario'
Go

Execute sp_addextendedproperty    @name       = 'MS_Description',
                                  @value      = 'Ultima Direccion IP desde donde se realiza la actualizacion del registro',
                                  @level0type = 'Schema',
                                  @level0name = 'dbo',
                                  @level1type = 'Table',
                                  @level1name = 'SO_AmortizacionUnidadProductoTbl',
                                  @level2type = 'Column',
                                  @level2name = 'ipAct'
Go
