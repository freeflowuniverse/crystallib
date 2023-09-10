module spreadsheet

pub fn (mut s Sheet) wiki_title_chart(args RowGetArgs) string {
	if args.title.len > 0 {
		titletxt := "
        title: {
          text: '${args.title}',
          subtext: '${args.title_sub}',
          left: 'center'
        },
        "
		return titletxt
	}
	return ''
}

// produce a nice looking bar chart see
// https://echarts.apache.org/examples/en/editor.html?c=line-stack
pub fn (mut s Sheet) wiki_line_chart(args_ []RowGetArgs) !string {
	// mut args := args_

	row_headers := args_.map(s.header_get_as_string(it.period_type)!)
	if row_headers.any(it != row_headers[0]) {
		return error('All rows in a line chart should have the same header')
	}

	row_names := args_.map(it.rowname)

	mut series_lines := []string{}
	for arg in args_ {
		series_lines << '{
          name: \'${arg.rowname}\',
          type: \'line\',
          stack: \'Total\',
          data: [${s.data_get_as_string(arg)!}]
        }'
	}

	// header := s.header_get_as_string(args.period_type)!
	// data := s.data_get_as_string(args)!
	// println('HERE! ${header}')
	// println('HERE!! ${data}')

	template := "
      ${s.wiki_title_chart(args_[0])}
      tooltip: {
        trigger: 'axis'
      },
      legend: {
        data: ${row_names}
      },
      grid: {
        left: '3%',
        right: '4%',
        bottom: '3%',
        containLabel: true
      },
      toolbox: {
        feature: {
          saveAsImage: {}
        }
      },
      xAxis: {
        type: 'category',
        boundaryGap: false,
        data: [${row_headers[0]}]
      },
      yAxis: {
        type: 'value'
      },
      series: [${series_lines.join(',')}] 
  "
	out := remove_empty_line('```echarts\n{${template}\n};\n```\n')
	println(out)
	// if true{panic("Sdsdsd")}
	return out
}

// produce a nice looking bar chart see
// https://echarts.apache.org/examples/en/index.html#chart-type-bar
pub fn (mut s Sheet) wiki_bar_chart(args_ RowGetArgs) !string {
	mut args := args_
	header := s.header_get_as_string(args.period_type)!
	data := s.data_get_as_string(args)!
	bar1 := "
      ${s.wiki_title_chart(args)}
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
	out := remove_empty_line('```echarts\n{${bar1}\n};\n```\n')
	println(out)
	// if true{panic("Sdsdsd")}
	return out
}

// produce a nice looking bar chart see
// https://echarts.apache.org/examples/en/index.html#chart-type-bar
pub fn (mut s Sheet) wiki_pie_chart(args_ RowGetArgs) !string {
	mut args := args_
	header := s.header_get_as_list(args.period_type)!
	data := s.data_get_as_list(args)!

	mut radius := ''
	if args.size.len > 0 {
		radius = "radius: '${args.size}',"
	}

	if header.len != data.len {
		return error('data and header lengths must match')
	}

	mut data_lines := []string{}
	for i, _ in data {
		data_lines << '{ value: ${data[i]}, name: ${header[i]}}'
	}
	data_str := '[${data_lines.join(',')}]'

	bar1 := "
    ${s.wiki_title_chart(args)}
    tooltip: {
      trigger: 'item'
    },
    legend: {
      orient: 'vertical',
      left: 'left'
    },
    series: [
      {
        name: 'Access From',
        type: 'pie',
        ${radius}
        data: ${data_str},
        emphasis: {
          itemStyle: {
            shadowBlur: 10,
            shadowOffsetX: 0,
            shadowColor: 'rgba(0, 0, 0, 0.5)'
          }
        }
      }
    ]

    "
	out := remove_empty_line('```echarts\n{${bar1}\n};\n```\n')
	println(out)
	// if true{panic("Sdsdsd")}
	return out
}
