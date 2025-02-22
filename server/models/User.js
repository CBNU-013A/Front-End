const mongoose = require("mongoose");

const UserSchema = new mongoose.Schema({
  id: String,
  name: String,
  email: { type: String, required: true, unique: true },
  password: { type: String, required: true },
  age: { type: Number, required: false },
  recentsearch: [{ type: String, required: false }],
  keywords: [{ type: mongoose.Schema.Types.ObjectId, ref: "Keyword" }],
  address: { type: String, required: false },
  birthdate: { type: Date, required: true },
});

module.exports = mongoose.model("User", UserSchema);
