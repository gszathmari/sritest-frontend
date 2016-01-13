# HTML Subresource Integrity Tester Frontend

This is the frontend of [sritest.io](https://sritest.io)

[![Travis branch](https://img.shields.io/travis/gszathmari/sritest-frontend/master.svg)](https://travis-ci.org/gszathmari/sritest-frontend)
[![](https://badge.imagelayers.io/gszathmari/sritest-frontend:latest.svg)](https://imagelayers.io/?images=gszathmari/sritest-frontend:latest 'Get your own badge on imagelayers.io')
[![Code Climate](https://codeclimate.com/github/gszathmari/sritest-frontend/badges/gpa.svg)](https://codeclimate.com/github/gszathmari/sritest-frontend)

## Running the application

Install the dependencies first with the following commands:

```
$ npm install
```

```
$ npm install -g
```

### Developer mode

Simply run the service with gulp:

```
$ gulp develop && gulp serve
```

### Production

Build files with Gulp first:

```
$ gulp build
```

Then copy the files under `dist/` to your favorite webserver. The frontend is static,
so the files can be just dumped into a S3 bucket.

## Testing

TBD

## Contributors

- [Gabor Szathmari](http://gaborszathmari.me) - [@gszathmari](https://twitter.com/gszathmari)

## License

See the [LICENSE](LICENSE) file for license rights and limitations (MIT)
