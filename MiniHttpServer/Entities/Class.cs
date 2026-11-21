using MiniHttpServer.ORM.Attributes;

namespace MiniHttpServer.Entities;

[TableName("classes")]
public class Class
{
    [PrimaryKey]
    [ColumnName("id")]
    public long Id { get; set; }
    
    [ColumnName("name")]
    public string Name { get; set; }
    
    [ColumnName("ornament_svg_path")]
    public string OrnamentSvgPath { get; set; }
    
    [ColumnName("slug")]
    public string Slug { get; set; }
}

