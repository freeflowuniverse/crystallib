module spreadsheet

import freeflowuniverse.crystallib.markdowndocs


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

pub fn (mut s Sheet) wiki_row_overview(args RowGetArgs) !string {
	table := markdowndocs.Table{
		header: ['Row Name', 'Description', 'Tags']
		rows: s.rows.values().map([it.name, it.description, it.tags])
		alignments: [.left, .left, .left]
	}
	return table.wiki()
}

// produce a nice looking bar chart see
// https://echarts.apache.org/examples/en/editor.html?c=line-stack
pub fn (mut s Sheet) wiki_line_chart(args_ RowGetArgs) !string {
  mut args:=args_
	header := s.header_get_as_string(args.period_type)!
	row_names := ["something"] //TODO: implement
	mut series_lines := []string{}

  series_lines << '{
        name: \'${row_names[0]}\',
        type: \'line\',
        stack: \'Total\',
        data: [${s.data_get_as_string(args)!}]
      }'

  //TODO: need to implement the multiple results which can come back from the args, can be more than 1

	// header := s.header_get_as_string(args.period_type)!
	// data := s.data_get_as_string(args)!
	// println('HERE! ${header}')
	// println('HERE!! ${data}')

	template := "
      ${s.wiki_title_chart(args)}
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
        data: [${header}]
      },
      yAxis: {
        type: 'value'
      },
      series: [${series_lines.join(',')}] 
  "
	out := remove_empty_line('```echarts\n{${template}\n};\n```\n')
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
	// if true{panic("Sdsdsd")}
	return out
}
