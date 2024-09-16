const express = require("express");
const app = express();
const stripe = require("stripe")("sk_test_51NOGeVCp1hoguf4zNQEDdPBrSsigSCGOMRdHz3KrPcLWN7tcYBxuYc2CS8ErHl2w2tATWlwVTSktQpEOooxZDX4s00wDmxhylf");

app.use(express.json());

app.post("/create-payment-intent", async (req, res) => {
  const { amount, currency } = req.body;

  try {
    const paymentIntent = await stripe.paymentIntents.create({
      amount: amount, // Suma plății în cenți
      currency: currency, // Moneda (de ex. 'ron')
    });

    res.send({
      clientSecret: paymentIntent.client_secret,
    });
  } catch (error) {
    return res.status(500).send({ error: error.message });
  }
});

app.listen(3000, () => {
  console.log("Serverul rulează pe portul 3000");
});
