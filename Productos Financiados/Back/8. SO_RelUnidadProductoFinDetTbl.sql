Use SisArrendaCredito
Go

--
-- Tabla:       SO_RelUnidadProductoFinDetTbl
--              Tabla Relación de productos a financiar relacionados a una Unidad
-- Modulo:      Originación
-- Fecha:       01-May-2026
-- Versión:     1
-- Programador: Pedro Zambrano
--

If Exists (Select Top 1 1
           From   SysObjects
           Where  Uid = 1
           And    Type = 'U'
           And    Name = 'SO_RelUnidadProductoFinDetTbl')
   Begin
      Drop Table dbo.SO_RelUnidadProductoFinDetTbl
   End
Go

Create Table dbo.SO_RelUnidadProductoFinDetTbl
  (idRelacion            Integer        Not Null,
   prod_id               Integer        Not Null,
   secuencia             Integer        Not Null,
   precioLista           Decimal(18, 2) Not Null,
   descuento             Decimal(18, 2) Not Null Default 0,
   precioneto            Decimal(18, 2) Not Null,
   tasaIva               Decimal(18, 4) Not Null Default 0,
   montoIva              Decimal(18, 2) Not Null,
   precioTotal           Decimal(18, 2) Not Null,
   idEstatus             Integer        Not Null Default 1,
   borradoLogico         Bit            Not Null Default 0,
   fechaAlta             Datetime       Not Null Default Getdate(),
   ultActual             Datetime       Not Null Default Getdate(),
   usuario               Varchar(10)    Not Null,
   ipAct                 Varchar(30)        Null,
   Constraint SO_RelUnidadProductoFinDetPk
   Primary Key (idRelacion, prod_id, secuencia),
   Constraint SO_RelUnidadProductoFinDetFk01
   Foreign Key (idRelacion)
   References dbo.SO_RelUnidadProductoFinTbl(idRelacion) on Delete Cascade,
   Constraint SO_RelUnidadProductoFinDetFk02
   Foreign Key (prod_id)
   References dbo.producto(prod_id) on Delete Cascade,
   Constraint SO_RelUnidadProductoFinDetCk01
   Check(idEstatus Between 0 And 1))
   On [Primary]
Go

--
-- Comentarios
--

Execute sp_addextendedproperty    @name       = 'MS_Description',
                                  @value      = 'Tabla Relación de productos a financiar relacionados a una Unidad.',
                                  @level0type = 'Schema',
                                  @level0name = 'dbo',
                                  @level1type = 'Table',
                                  @level1name = 'SO_RelUnidadProductoFinDetTbl'
Go

Execute sp_addextendedproperty    @name       = 'MS_Description',
                                  @value      = 'Identificador de la Relación de la Unidad con los productos a financiar.',
                                  @level0type = 'Schema',
                                  @level0name = 'dbo',
                                  @level1type = 'Table',
                                  @level1name = 'SO_RelUnidadProductoFinDetTbl',
                                  @level2type = 'Column',
                                  @level2name = 'idRelacion'
Go

Execute sp_addextendedproperty    @name       = 'MS_Description',
                                  @value      = 'Identificador del producto a financiar.',
                                  @level0type = 'Schema',
                                  @level0name = 'dbo',
                                  @level1type = 'Table',
                                  @level1name = 'SO_RelUnidadProductoFinDetTbl',
                                  @level2type = 'Column',
                                  @level2name = 'prod_id'
Go

Execute sp_addextendedproperty    @name       = 'MS_Description',
                                  @value      = 'Secuencia de la Relación del producto a financiar.',
                                  @level0type = 'Schema',
                                  @level0name = 'dbo',
                                  @level1type = 'Table',
                                  @level1name = 'SO_RelUnidadProductoFinDetTbl',
                                  @level2type = 'Column',
                                  @level2name = 'secuencia'
Go


Execute sp_addextendedproperty    @name       = 'MS_Description',
                                  @value      = 'Precio de Lista del Producto a financiar.',
                                  @level0type = 'Schema',
                                  @level0name = 'dbo',
                                  @level1type = 'Table',
                                  @level1name = 'SO_RelUnidadProductoFinDetTbl',
                                  @level2type = 'Column',
                                  @level2name = 'precioLista'
Go

Execute sp_addextendedproperty    @name       = 'MS_Description',
                                  @value      = 'Decuento aplicado al producto a financiar.',
                                  @level0type = 'Schema',
                                  @level0name = 'dbo',
                                  @level1type = 'Table',
                                  @level1name = 'SO_RelUnidadProductoFinDetTbl',
                                  @level2type = 'Column',
                                  @level2name = 'descuento'
Go

Execute sp_addextendedproperty    @name       = 'MS_Description',
                                  @value      = 'Precio Neto aplicado al producto a financiar.',
                                  @level0type = 'Schema',
                                  @level0name = 'dbo',
                                  @level1type = 'Table',
                                  @level1name = 'SO_RelUnidadProductoFinDetTbl',
                                  @level2type = 'Column',
                                  @level2name = 'precioneto'
Go

Execute sp_addextendedproperty    @name       = 'MS_Description',
                                  @value      = 'Porcentaje de Iva aplicado al producto a financiar.',
                                  @level0type = 'Schema',
                                  @level0name = 'dbo',
                                  @level1type = 'Table',
                                  @level1name = 'SO_RelUnidadProductoFinDetTbl',
                                  @level2type = 'Column',
                                  @level2name = 'tasaIva'
Go

Execute sp_addextendedproperty    @name       = 'MS_Description',
                                  @value      = 'Monto del Iva aplicado al producto a financiar.',
                                  @level0type = 'Schema',
                                  @level0name = 'dbo',
                                  @level1type = 'Table',
                                  @level1name = 'SO_RelUnidadProductoFinDetTbl',
                                  @level2type = 'Column',
                                  @level2name = 'montoIva'
Go

Execute sp_addextendedproperty    @name       = 'MS_Description',
                                  @value      = 'Precio Neto mas Iva aplicado al producto a financiar.',
                                  @level0type = 'Schema',
                                  @level0name = 'dbo',
                                  @level1type = 'Table',
                                  @level1name = 'SO_RelUnidadProductoFinDetTbl',
                                  @level2type = 'Column',
                                  @level2name = 'precioTotal'
Go

Execute sp_addextendedproperty    @name       = 'MS_Description',
                                  @value      = 'Identificador del Estatus del Producto en laa relación. 0 = Inactivo, 1 = Activo',
                                  @level0type = 'Schema',
                                  @level0name = 'dbo',
                                  @level1type = 'Table',
                                  @level1name = 'SO_RelUnidadProductoFinDetTbl',
                                  @level2type = 'Column',
                                  @level2name = 'idEstatus'
Go

Execute sp_addextendedproperty    @name       = 'MS_Description',
                                  @value      = 'Identificador del Registro si esta de baja. 0 = Activo, 1 = Baja',
                                  @level0type = 'Schema',
                                  @level0name = 'dbo',
                                  @level1type = 'Table',
                                  @level1name = 'SO_RelUnidadProductoFinDetTbl',
                                  @level2type = 'Column',
                                  @level2name = 'borradoLogico'
Go

Execute sp_addextendedproperty    @name       = 'MS_Description',
                                  @value      = 'Fecha de Alta de la Relación del producto con la Unidad',
                                  @level0type = 'Schema',
                                  @level0name = 'dbo',
                                  @level1type = 'Table',
                                  @level1name = 'SO_RelUnidadProductoFinDetTbl',
                                  @level2type = 'Column',
                                  @level2name = 'fechaAlta'
Go

Execute sp_addextendedproperty    @name       = 'MS_Description',
                                  @value      = 'Ultima Fecha de actualizacion del registro',
                                  @level0type = 'Schema',
                                  @level0name = 'dbo',
                                  @level1type = 'Table',
                                  @level1name = 'SO_RelUnidadProductoFinDetTbl',
                                  @level2type = 'Column',
                                  @level2name = 'ultActual'
Go

Execute sp_addextendedproperty    @name       = 'MS_Description',
                                  @value      = 'Ultima Usuario que realiza la actualizacion del registro',
                                  @level0type = 'Schema',
                                  @level0name = 'dbo',
                                  @level1type = 'Table',
                                  @level1name = 'SO_RelUnidadProductoFinDetTbl',
                                  @level2type = 'Column',
                                  @level2name = 'usuario'
Go

Execute sp_addextendedproperty    @name       = 'MS_Description',
                                  @value      = 'Ultima Direccion IP desde donde se realiza la actualizacion del registro',
                                  @level0type = 'Schema',
                                  @level0name = 'dbo',
                                  @level1type = 'Table',
                                  @level1name = 'SO_RelUnidadProductoFinDetTbl',
                                  @level2type = 'Column',
                                  @level2name = 'ipAct'
Go
