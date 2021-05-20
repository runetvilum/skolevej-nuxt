const path = require('path')
const puppeteer = require('puppeteer')
const OSRM = require('osrm')
const app = require('express')()
const bodyParser = require('body-parser')
app.use(bodyParser.json())
const klasser = [
  {
    text: '0. klasse',
    value: 0,
    route: '0-3',
    max: 2500,
  },
  {
    text: '1. klasse',
    value: 1,
    route: '0-3',
    max: 2500,
  },
  {
    text: '2. klasse',
    value: 2,
    route: '0-3',
    max: 2500,
  },
  {
    text: '3. klasse',
    value: 3,
    route: '0-3',
    max: 2500,
  },
  {
    text: '4. klasse',
    value: 4,
    route: '4-6',
    max: 6000,
  },
  {
    text: '5. klasse',
    value: 5,
    route: '4-6',
    max: 6000,
  },
  {
    text: '6. klasse',
    value: 6,
    route: '4-6',
    max: 6000,
  },
  {
    text: '7. klasse',
    value: 7,
    route: '7-10',
    max: 7000,
  },
  {
    text: '8. klasse',
    value: 8,
    route: '7-10',
    max: 7000,
  },
  {
    text: '9. klasse',
    value: 9,
    route: '7-10',
    max: 7000,
  },
  {
    text: '10. klasse',
    value: 10,
    route: '7-10',
    max: 9000,
  },
  {
    text: 'Alle veje',
    value: 11,
    route: 'all',
    max: 9000,
  },
]
const data = {
  bicycle: {
    '0-3': new OSRM({
      path: path.join(__dirname, '../osrm/bicycle/Skolevej_0-3.osrm'),
      algorithm: 'MLD',
    }),
    '4-6': new OSRM({
      path: path.join(__dirname, '../osrm/bicycle/Skolevej_4-6.osrm'),
      algorithm: 'MLD',
    }),
    '7-10': new OSRM({
      path: path.join(__dirname, '../osrm/bicycle/Skolevej_7-10.osrm'),
      algorithm: 'MLD',
    }),
    all: new OSRM({
      path: path.join(__dirname, '../osrm/bicycle/Vejmidte.osrm'),
      algorithm: 'MLD',
    }),
  },
  car: {
    '0-3': new OSRM({
      path: path.join(__dirname, '../osrm/car/Skolevej_0-3.osrm'),
      algorithm: 'MLD',
    }),
    '4-6': new OSRM({
      path: path.join(__dirname, '../osrm/car/Skolevej_4-6.osrm'),
      algorithm: 'MLD',
    }),
    '7-10': new OSRM({
      path: path.join(__dirname, '../osrm/car/Skolevej_7-10.osrm'),
      algorithm: 'MLD',
    }),
    all: new OSRM({
      path: path.join(__dirname, '../osrm/car/Vejmidte.osrm'),
      algorithm: 'MLD',
    }),
  },
  foot: {
    '0-3': new OSRM({
      path: path.join(__dirname, '../osrm/foot/Skolevej_0-3.osrm'),
      algorithm: 'MLD',
    }),
    '4-6': new OSRM({
      path: path.join(__dirname, '../osrm/foot/Skolevej_4-6.osrm'),
      algorithm: 'MLD',
    }),
    '7-10': new OSRM({
      path: path.join(__dirname, '../osrm/foot/Skolevej_7-10.osrm'),
      algorithm: 'MLD',
    }),
    all: new OSRM({
      path: path.join(__dirname, '../osrm/foot/Vejmidte.osrm'),
      algorithm: 'MLD',
    }),
  },
}
const route = (transport, klasse, coordinates, retning) => {
  return new Promise((resolve, reject) => {
    const a = klasser[klasse]
    data[transport][a.route].route(
      {
        coordinates:
          retning === 0 ? coordinates : [coordinates[1], coordinates[0]],
        continue_straight: false,
        overview: 'false',
        geometries: 'polyline6',
        steps: true,
      },
      (err, result) => {
        if (err) {
          return reject(err)
        }
        resolve(result)
      }
    )
  })
}
app.post('/route', async (req, res, next) => {
  try {
    const result = await route(
      req.body.transport,
      req.body.klasse,
      req.body.coordinates,
      req.body.retning
    )

    const farlig =
      result.waypoints[0].distance > 100 || result.waypoints[1].distance > 100
    res.json({
      tilskud:
        farlig || result.routes[0].distance > klasser[req.body.klasse].max,
      farlig,
      ...result,
    })
  } catch (err) {
    next(err)
  }
})
/*
app.post('/route', async (req, res, next) => {
  // req.body.geometries = 'geojson'
  let farlig = false
  let fejl = false
  let result
  let resultReverse
  try {
    result = await route(
      req.body.transport,
      req.body.klasse,
      req.body.coordinates
    )
    resultReverse = await route(req.body.transport, req.body.klasse, [
      req.body.coordinates[1],
      req.body.coordinates[0],
    ])
    if (result.routes[0].distance < resultReverse.routes[0].distance) {
      result = resultReverse
    }

    farlig =
      result.waypoints[0].distance > 50 || result.waypoints[1].distance > 50
  } catch (err) {
    fejl = true
  }
  try {
    if (farlig || fejl) {
      result = await route(req.body.transport, 11, req.body.coordinates)
      resultReverse = await route(req.body.transport, 11, [
        req.body.coordinates[1],
        req.body.coordinates[0],
      ])
      if (result.routes[0].distance < resultReverse.routes[0].distance) {
        result = resultReverse
      }
    }
    res.json({
      tilskud:
        farlig || result.routes[0].distance > klasser[req.body.klasse].max,
      farlig,
      fejl,
      ...result,
    })
  } catch (err) {
    try {
      result = await route('car', 11, req.body.coordinates)
      res.json({
        tilskud:
          farlig || result.routes[0].distance > klasser[req.body.klasse].max,
        farlig,
        fejl,
        ...result,
      })
    } catch (err) {
      next(err)
    }
  }
})
*/
app.get(
  '/pdf/:adresse/:klasse/:skole/:transport/:retning',
  async (req, res) => {
    try {
      const browser = await puppeteer.launch({
        headless: true,
        args: ['--no-sandbox', '--disable-gpu'],
      })
      const page = await browser.newPage()
      await page.goto(
        `http://localhost:3000/print?adresse=${req.params.adresse}&klasse=${req.params.klasse}&skole=${req.params.skole}&transport=${req.params.transport}&retning=${req.params.retning}`,
        { waitUntil: 'networkidle2' }
      )
      const buf = await page.pdf({ format: 'A4' })
      await browser.close()
      res.setHeader('Content-Length', buf.length)
      res.setHeader('Content-Type', 'application/pdf')
      res.setHeader('Content-Disposition', 'attachment; filename="tilskud.pdf"')
      res.send(buf)
    } catch (err) {
      console.log(err)
      res.json(err)
    }
  }
)

module.exports = app
