function monitorUptime(url) {

}

const result = monitorUptime('http://localhost:8081/healthcheck/')


function updateTabNames() {

  console.log('🌞 updateTabNames: ', $('.nav.nav-tabs').length)

  const findArr = [
    'learning.gww.gov.bc.ca - Traffic'
  ]

  const replaceArr = [
    'Moodle - Traffic'
  ]

  $('.nav.nav-tabs').each(function() {
    for (var x = 0; x < findArr.length; x++) {
      $(this).find('a').each(function() {

        console.log('🌞 Found link: ', $(this))

        if ($(this).html().indexOf(findArr[x]) >= 0) {

          console.log('🌞 MATCH ON link: ', findArr[x])
          console.log('🌞 Replace with: ', replaceArr[x])

          $(this).html(replaceArr[x])
        }
      })
    }
  })
}
