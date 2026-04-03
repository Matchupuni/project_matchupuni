const uploadFile = (req, res) => {
  if (!req.file) {
    return res.status(400).json({ error: 'No file uploaded' });
  }
  const filePath = `/public/uploads/${req.file.filename}`;
  res.json({ path: filePath, filename: req.file.filename });
};

module.exports = {
  uploadFile
};
