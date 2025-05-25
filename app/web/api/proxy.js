module.exports = async function handler(req, res) {
    const { url } = req.query;

    if(!url) return res.status(400).json({ error: 'URL parameter is required' });

    try {
        const response = await fetch(url);
        if(!response.ok) throw new Error(`Failed to fetch image: ${response.status} ${response.statusText}`);

        const buffer = await response.arrayBuffer();
        res.setHeader('Access-Control-Allow-Origin', '*');
        res.setHeader('Content-Type', res.headers.get('content-type') || 'image/jpeg');

        return res.send(Buffer.from(buffer));
    } catch(e) {
        return res.status(500).json({ error: 'Failed to fetch image' });
    }
}