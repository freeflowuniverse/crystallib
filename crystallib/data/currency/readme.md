# currency handling


```v

import freeflowuniverse.crystallib.data.currency

mut a:=amount_get('20 k tft')!
assert a.currency.usdval == 0.01
assert a.usd() == 20.0*0.01*1000

mut c:=get("USD")! //to get a currency

```

