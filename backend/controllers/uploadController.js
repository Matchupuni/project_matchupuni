const uploadFile = (req, res) => {
  if (!req.files || req.files.length === 0) {
    return res.status(400).json({ error: 'No file uploaded' });
  }
  const filePaths = req.files.map(file => `/public/uploads/${file.filename}`);
  res.json({ paths: filePaths });
};

module.exports = {
  uploadFile
};
