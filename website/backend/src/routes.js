const express = require('express');
const MongoClient = require('mongodb').MongoClient;

const router = express.Router();

// retrieve latest micro-posts
router.get('/', async (req, res) => {
  const collection = await loadMicroPostsCollection();
  res.send(
    await collection.find({}).toArray()
  );
});

// insert a new micro-post
router.post('/', async (req, res) => {
  const collection = await loadMicroPostsCollection();
  await collection.insertOne({
    text: req.body.text,
    createdAt: new Date(),
  });
  res.status(200).send();
});


module.exports = router;