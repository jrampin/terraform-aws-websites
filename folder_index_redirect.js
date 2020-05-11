const { extname } = require('path');

exports.handler = async function(event) {
    const request = event.Records[0].cf.request;

    const requestPath = request.uri;

    if (looksLikeADirectory(requestPath) && !requestPath.endsWith('/')) {
        const pathWithSlash = `${requestPath}/`;

        return makeRedirect301Response(pathWithSlash, request.querystring);
    }

    if (requestPath.endsWith('/')) {
        const pathWithIndexHtml = `${requestPath}index.html`;

        return makeOriginRequestWithNewPath(request, pathWithIndexHtml);
    }
    
    return request;
};

function makeRedirect301Response(path, queryString) {
    const redirectUri = combineUriParts(path, queryString);

    return {
        body: '',
        status: '301',
        statusDescription: 'Moved Permanently',
        headers: {
            location: [
                {
                    value: redirectUri,
                },
            ],
        },
    };
}

function looksLikeADirectory(path) {
    const fileExtension = extname(path);

    return fileExtension === '';
}

function makeOriginRequestWithNewPath(request, path) {
    return {
        ...request,
        uri: path,
    };
}

function combineUriParts(path, queryString) {
    return queryString
        ? `${path}?${queryString}`
        : path;
}