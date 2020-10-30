import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import * as firebaseHelper from "firebase-functions-helper/dist";
import * as express from "express";
import * as bodyParser from "body-parser";

admin.initializeApp(functions.config().firebase);
const db = admin.firestore();

const app = express();
const main = express();

main.use(bodyParser.json());
main.use(bodyParser.urlencoded({ extended: false }));
main.use("/api/v1", app);

const postsCollection = "posts";

export const webApi = functions.https.onRequest(main);

interface Post {
  title: String;
  day: String;
  date: Date;
  description: String;
  image: String;
  todayInOneSentence: String;
  heading: String;
  content: String;
}

// Get a post by day
app.get("/posts/:day", (req, res) => {
  const day = req.params.day.toLowerCase()
  const queryArray = [
    ["day", "==", day]
  ];

  firebaseHelper.firestore
    .queryData(db, postsCollection, queryArray)
    .then((doc) => res.status(200).send(doc))
    .catch((error) => res.status(400).send(`Cannot get post: ${error}`));
});

// Get all posts
app.get("/posts", (req, res) => {
  firebaseHelper.firestore
    .backup(db, postsCollection)
    .then((data) => res.status(200).send(data))
    .catch((error) => res.status(400).send(`Cannot get posts: ${error}`));
});

// Add a new post // ! TODO: If the post already exists, we need to update it
app.post("/posts", async (req, res) => {
  try {
    const post: Post = {
      title: req.body["title"],
      day: req.body["day"],
      date: req.body["date"],
      description: req.body["description"],
      image: req.body["image"],
      todayInOneSentence: req.body["todayInOneSentence"],
      heading: req.body["heading"],
      content: req.body["content"]
    };

    const newDoc = await firebaseHelper.firestore.createDocumentWithID(
      db,
      'posts',
      req.body["day"],
      post
    );
    res.status(201).send(`Created a new post: ${newDoc}`);
  } catch (error) {
    res.status(400).send(`Error: <br /><pre>${error}</pre>`);
  }
});

// Update a post
app.patch("/posts/:day", async (req, res) => {
  const updatedDoc = await firebaseHelper.firestore.updateDocument(
    db,
    postsCollection,
    req.params.day,
    req.body
  );
  res.status(204).send(`Updated post: ${updatedDoc}`);
});

// Delete a post
app.delete("/posts/:day", async (req, res) => {
  const deletedPost = await firebaseHelper.firestore.deleteDocument(
    db,
    postsCollection,
    req.params.day
  );
  res.status(204).send(`Post has been deleted deleted: ${deletedPost}`);
});

export { app };
