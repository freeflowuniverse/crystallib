module.exports = {
    content: [@{content_paths}],
    safelist: [
      {
          pattern: /(-|)(ml|mr)-(4|8|12|16|20|24|28)/,
          variants: ['sm', 'md', 'lg', 'first', 'first:sm', 'first:md', 'first:lg', 'last', 'last:sm', 'last:md', 'last:lg'],
      },
      {
          pattern: /(pt|pb)-(0)/,
          variants: ['!', 'lg', 'first', 'first:sm', 'first:md', 'first:lg', 'last', 'last:sm', 'last:md', 'last:lg'],
      }
    ],
    future: {
      // removeDeprecatedGapUtilities: true,
      // purgeLayersByDefault: true,
      // defaultLineHeights: true,
      // standardFontWeights: true
    },
    purge: {
      enabled: true,
      content: [
        './**/*.html'
      ]
    },
    theme: {
      fontFamily: {
        sans: ['Nunito', 'sans-serif'],
        display: ['Nunito', 'sans-serif'],
        body: ['Nunito', 'sans-serif']
      },
      extend: {
        colors: {
          primary: '#EA755E',
          secondary: '#BD675F'
        }
      }
    },
    variants: {},
    plugins: [
      require('tailwindcss'),
      require('autoprefixer'),
      require('@tailwindcss/typography')
    ]      
  }