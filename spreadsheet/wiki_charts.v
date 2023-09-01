module spreadsheet


//produce a nice looking bar chart see
// https://echarts.apache.org/examples/en/index.html#chart-type-bar
pub fn (mut s Sheet) wiki_bar_chart(args_ RowGetArgs) !string {
    mut args:=args_
    header:=s.header_get_as_string(args.period_type)!
    data:=s.data_get_as_string(args)!
    bar1:="
      xAxis: {
        type: 'category',
        data: [${header}]
      },
      yAxis: {
        type: 'value'
      },
      series: [
        {
          data: [${data}],
          type: 'bar',
          showBackground: true,
          backgroundStyle: {
            color: 'rgba(180, 180, 180, 0.2)'
          }
        }
      ]
    "
  out:=remove_empty_line("```echarts\n{${bar1}\n};\n```\n")
  println(out)
  // if true{panic("Sdsdsd")}
  return out

}