Use SisArrendaCredito
Go

--
-- Tabla:       SO_RelUnidadProductoFinAmorTbl
--              Tabla de Amortización de Productos Financiados
-- Modulo:      Originación
-- Fecha:       4-May-2026
-- Versión:     1
-- Programador: Pedro Zambrano
--

If Exists (Select Top 1 1
           From   SysObjects
           Where  Uid = 1
           And    Type = 'U'
           And    Name = 'SO_RelUnidadProductoFinAmorTbl')
   Begin
      Drop Table dbo.SO_RelUnidadProductoFinAmorTbl
   End
Go

Create Table dbo.SO_RelUnidadProductoFinAmorTbl
  (idRelacion            Integer        Not Null,
   amortiz_id            Integer        Not Null,
   fechaAmort            Date           Not Null,
   capital               Decimal(18, 2) Not Null,
   intereses             Decimal(18, 2) Not Null,
   gastos                Decimal(18, 2) Not Null Default 0,
   seguros               Decimal(18, 2) Not Null Default 0,
   idEstatus             Tinyint        Not Null Default 1,
   ultActual             Datetime       Not Null Default Getdate(),
   usuario               Varchar(10)    Not Null,
   ipAct                 Varchar(30)        Null,
   Constraint SO_RelUnidadProductoFinAmorPk
   Primary Key (idRelacion, amortiz_id),
   Constraint SO_RelUnidadProductoFinAmorFk01
   Foreign Key (idRelacion)
   References dbo.SO_RelUnidadProductoFinTbl(idRelacion) on Delete Cascade,
   Constraint SO_RelUnidadProductoFinAmorCk01
   Check(idEstatus Between 1 And 2))
   On [Primary]
Go

--
-- Comentarios
--

Execute sp_addextendedproperty    @name       = 'MS_Description',
                                  @value      = 'Tabla de Amortización de productos a financiar relacionados a una Unidad.',
                                  @level0type = 'Schema',
                                  @level0name = 'dbo',
                                  @level1type = 'Table',
                                  @level1name = 'SO_RelUnidadProductoFinAmorTbl'
Go

Execute sp_addextendedproperty    @name       = 'MS_Description',
                                  @value      = 'Identificador de la Relación de la Unidad con los productos a financiar.',
                                  @level0type = 'Schema',
                                  @level0name = 'dbo',
                                  @level1type = 'Table',
                                  @level1name = 'SO_RelUnidadProductoFinAmorTbl',
                                  @level2type = 'Column',
                                  @level2name = 'idRelacion'
Go

Execute sp_addextendedproperty    @name       = 'MS_Description',
                                  @value      = 'Numero de Amortización.',
                                  @level0type = 'Schema',
                                  @level0name = 'dbo',
                                  @level1type = 'Table',
                                  @level1name = 'SO_RelUnidadProductoFinAmorTbl',
                                  @level2type = 'Column',
                                  @level2name = 'amortiz_id'
Go

Execute sp_addextendedproperty    @name       = 'MS_Description',
                                  @value      = 'Fecha de la Amortización.',
                                  @level0type = 'Schema',
                                  @level0name = 'dbo',
                                  @level1type = 'Table',
                                  @level1name = 'SO_RelUnidadProductoFinAmorTbl',
                                  @level2type = 'Column',
                                  @level2name = 'fechaAmort'
Go

Execute sp_addextendedproperty    @name       = 'MS_Description',
                                  @value      = 'Monto del capital relacionada a la Amortización.',
                                  @level0type = 'Schema',
                                  @level0name = 'dbo',
                                  @level1type = 'Table',
                                  @level1name = 'SO_RelUnidadProductoFinAmorTbl',
                                  @level2type = 'Column',
                                  @level2name = 'capital'
Go


Execute sp_addextendedproperty    @name       = 'MS_Description',
                                  @value      = 'Monto del Interes relacionado a la Amortización.',
                                  @level0type = 'Schema',
                                  @level0name = 'dbo',
                                  @level1type = 'Table',
                                  @level1name = 'SO_RelUnidadProductoFinAmorTbl',
                                  @level2type = 'Column',
                                  @level2name = 'intereses'
Go

Execute sp_addextendedproperty    @name       = 'MS_Description',
                                  @value      = 'Cuotaparte de Gastos relacionado a la Amortización.',
                                  @level0type = 'Schema',
                                  @level0name = 'dbo',
                                  @level1type = 'Table',
                                  @level1name = 'SO_RelUnidadProductoFinAmorTbl',
                                  @level2type = 'Column',
                                  @level2name = 'gastos'
Go

Execute sp_addextendedproperty    @name       = 'MS_Description',
                                  @value      = 'Cuotaparte de Seguro relacionado a la Amortización.',
                                  @level0type = 'Schema',
                                  @level0name = 'dbo',
                                  @level1type = 'Table',
                                  @level1name = 'SO_RelUnidadProductoFinAmorTbl',
                                  @level2type = 'Column',
                                  @level2name = 'seguros'
Go

Execute sp_addextendedproperty    @name       = 'MS_Description',
                                  @value      = 'Identificador del Estatus de la cuota. 1 = Pendiente, 2 = Procesada',
                                  @level0type = 'Schema',
                                  @level0name = 'dbo',
                                  @level1type = 'Table',
                                  @level1name = 'SO_RelUnidadProductoFinAmorTbl',
                                  @level2type = 'Column',
                                  @level2name = 'idEstatus'
Go

Execute sp_addextendedproperty    @name       = 'MS_Description',
                                  @value      = 'Ultima Fecha de actualizacion del registro',
                                  @level0type = 'Schema',
                                  @level0name = 'dbo',
                                  @level1type = 'Table',
                                  @level1name = 'SO_RelUnidadProductoFinAmorTbl',
                                  @level2type = 'Column',
                                  @level2name = 'ultActual'
Go

Execute sp_addextendedproperty    @name       = 'MS_Description',
                                  @value      = 'Ultima Usuario que realiza la actualizacion del registro',
                                  @level0type = 'Schema',
                                  @level0name = 'dbo',
                                  @level1type = 'Table',
                                  @level1name = 'SO_RelUnidadProductoFinAmorTbl',
                                  @level2type = 'Column',
                                  @level2name = 'usuario'
Go

Execute sp_addextendedproperty    @name       = 'MS_Description',
                                  @value      = 'Ultima Direccion IP desde donde se realiza la actualizacion del registro',
                                  @level0type = 'Schema',
                                  @level0name = 'dbo',
                                  @level1type = 'Table',
                                  @level1name = 'SO_RelUnidadProductoFinAmorTbl',
                                  @level2type = 'Column',
                                  @level2name = 'ipAct'
Go
