Use SisArrendaCredito
Go

--
-- Tabla:   SO_RelUnidadProductoFinTbl
--          Tabla de Maestra de la Relación de la Unidad con los productos a financiar
-- Modulo:  Originación
-- Fecha:   07-may-2026
-- Version: 2
--

If Exists (Select Top 1 1
           From   SysObjects
           Where  Uid = 1
           And    Type = 'U'
           And    Name = 'SO_RelUnidadProductoFinTbl')
   Begin
      Drop Table dbo.SO_RelUnidadProductoFinTbl
   End
Go

Create Table dbo.SO_RelUnidadProductoFinTbl
  (Id_Unidad             Integer        Not Null,
   prod_id               Integer        Not Null,
   montoFinanciar        Decimal(18, 2) Not Null,
   noamort               Integer        Not Null,
   tasaFinanciamiento    Decimal(18, 4) Not Null,
   totalIntereses        Decimal(18, 2) Not Null Default 0,
   idEstatus             Integer        Not Null Default 1,
   borradoLogico         Bit            Not Null Default 0,
   fechaAlta             Datetime       Not Null Default Getdate(),
   ultActual             Datetime       Not Null Default Getdate(),
   usuario               Varchar(10)    Not Null,
   ipAct                 Varchar(30)        Null,
   Constraint   SO_RelUnidadProductoFinPk
   Primary Key (Id_Unidad, prod_id),
   Constraint   SO_RelUnidadProductoFinFk01
   Foreign Key (Id_Unidad)
   References   dbo.SO_Unidades(id_Unidad),
   Constraint   SO_RelUnidadProductoFinDetFk02
   Foreign Key (prod_id)
   References   dbo.producto(prod_id) on Delete Cascade)
Go

--
-- Comentarios
--

Execute sp_addextendedproperty    @name       = 'MS_Description',
                                  @value      = 'Tabla Maestra de la Relación de la Unidad con los productos a financiar.',
                                  @level0type = 'Schema',
                                  @level0name = 'dbo',
                                  @level1type = 'Table',
                                  @level1name = 'SO_RelUnidadProductoFinTbl'
Go


Execute sp_addextendedproperty    @name       = 'MS_Description',
                                  @value      = 'Identificador Unico de la Unidad a la cual se le va a relaciones los productos a financiar.',
                                  @level0type = 'Schema',
                                  @level0name = 'dbo',
                                  @level1type = 'Table',
                                  @level1name = 'SO_RelUnidadProductoFinTbl',
                                  @level2type = 'Column',
                                  @level2name = 'Id_Unidad'
Go

Execute sp_addextendedproperty    @name       = 'MS_Description',
                                  @value      = 'Identificador Unico del producto a financiar relacionado a la Unidad.',
                                  @level0type = 'Schema',
                                  @level0name = 'dbo',
                                  @level1type = 'Table',
                                  @level1name = 'SO_RelUnidadProductoFinTbl',
                                  @level2type = 'Column',
                                  @level2name = 'prod_id'
Go

Execute sp_addextendedproperty    @name       = 'MS_Description',
                                  @value      = 'Monto a financiar del producto.',
                                  @level0type = 'Schema',
                                  @level0name = 'dbo',
                                  @level1type = 'Table',
                                  @level1name = 'SO_RelUnidadProductoFinTbl',
                                  @level2type = 'Column',
                                  @level2name = 'montoFinanciar'
Go

Execute sp_addextendedproperty    @name       = 'MS_Description',
                                  @value      = 'Numero de Amortizaciones del producto a financiar.',
                                  @level0type = 'Schema',
                                  @level0name = 'dbo',
                                  @level1type = 'Table',
                                  @level1name = 'SO_RelUnidadProductoFinTbl',
                                  @level2type = 'Column',
                                  @level2name = 'noamort'
Go

Execute sp_addextendedproperty    @name       = 'MS_Description',
                                  @value      = 'Tasa del Financiamiento a ser Aplicados al Producto.',
                                  @level0type = 'Schema',
                                  @level0name = 'dbo',
                                  @level1type = 'Table',
                                  @level1name = 'SO_RelUnidadProductoFinTbl',
                                  @level2type = 'Column',
                                  @level2name = 'tasaFinanciamiento';
Go

Execute sp_addextendedproperty    @name       = 'MS_Description',
                                  @value      = 'Monto Total de Intereses Aplicados al Producto.',
                                  @level0type = 'Schema',
                                  @level0name = 'dbo',
                                  @level1type = 'Table',
                                  @level1name = 'SO_RelUnidadProductoFinTbl',
                                  @level2type = 'Column',
                                  @level2name = 'totalIntereses'
Go

Execute sp_addextendedproperty    @name       = 'MS_Description',
                                  @value      = 'Identificador del Estatus de la Relación de la Unidad con los productos a financiar',
                                  @level0type = 'Schema',
                                  @level0name = 'dbo',
                                  @level1type = 'Table',
                                  @level1name = 'SO_RelUnidadProductoFinTbl',
                                  @level2type = 'Column',
                                  @level2name = 'idEstatus'
Go

Execute sp_addextendedproperty    @name       = 'MS_Description',
                                  @value      = 'Flag que indica si la Relación de la Unidad con los productos a financiar esta activa',
                                  @level0type = 'Schema',
                                  @level0name = 'dbo',
                                  @level1type = 'Table',
                                  @level1name = 'SO_RelUnidadProductoFinTbl',
                                  @level2type = 'Column',
                                  @level2name = 'borradoLogico'
Go

Execute sp_addextendedproperty    @name       = 'MS_Description',
                                  @value      = 'Fecha de Alta de la Relación de la Unidad con los productos a financiar esta activa',
                                  @level0type = 'Schema',
                                  @level0name = 'dbo',
                                  @level1type = 'Table',
                                  @level1name = 'SO_RelUnidadProductoFinTbl',
                                  @level2type = 'Column',
                                  @level2name = 'fechaAlta'
Go

Execute sp_addextendedproperty    @name       = 'MS_Description',
                                  @value      = 'Ultima Fecha de actualizacion del registro',
                                  @level0type = 'Schema',
                                  @level0name = 'dbo',
                                  @level1type = 'Table',
                                  @level1name = 'SO_RelUnidadProductoFinTbl',
                                  @level2type = 'Column',
                                  @level2name = 'ultActual'
Go

Execute sp_addextendedproperty    @name       = 'MS_Description',
                                  @value      = 'Ultima Usuario que realiza la actualizacion del registro',
                                  @level0type = 'Schema',
                                  @level0name = 'dbo',
                                  @level1type = 'Table',
                                  @level1name = 'SO_RelUnidadProductoFinTbl',
                                  @level2type = 'Column',
                                  @level2name = 'usuario'
Go

Execute sp_addextendedproperty    @name       = 'MS_Description',
                                  @value      = 'Ultima Direccion IP desde donde se realiza la actualizacion del registro',
                                  @level0type = 'Schema',
                                  @level0name = 'dbo',
                                  @level1type = 'Table',
                                  @level1name = 'SO_RelUnidadProductoFinTbl',
                                  @level2type = 'Column',
                                  @level2name = 'ipAct'
Go
