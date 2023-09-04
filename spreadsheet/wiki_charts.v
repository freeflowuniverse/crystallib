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
	header := s.header_get_as_string(args.period_type)!
	data := s.data_get_as_string(args)!

	mut radius := ''
	if args.size.len > 0 {
		radius = "radius: '${args.size}',"
	}

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
        data: [
          { value: 1048, name: 'Search Engine' },
          { value: 735, name: 'Direct' },
          { value: 580, name: 'Email' },
          { value: 484, name: 'Union Ads' },
          { value: 300, name: 'Video Ads' }
        ],
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
