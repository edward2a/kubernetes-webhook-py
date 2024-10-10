#!/usr/bin/env python3

import falcon

from wsgiref.simple_server import make_server

class HealthHandler(object):

    def on_get(self, req, resp):
        """Return HTTP/204."""
        resp.status = falcon.HTTP_NO_CONTENT

class ValidatingWebhookHandler(object):

    def on_post(self, req, resp):
        """Process validation request and respond."""
        print(req.media)
        resp.media = {
            'apiVersion': 'admission.k8s.io/v1',
            'kind': 'AdmissionReview',
            'response': {
              'allowed': True,
              'uid': req.media['request']['uid'],
              'status': {'message': 'default approval'}
            }
        }



def main():
    app = falcon.App()
    app.add_route('/health', HealthHandler())
    app.add_route('/validate', ValidatingWebhookHandler())

    with make_server('0.0.0.0', 8080, app) as httpd:
        httpd.serve_forever()

if __name__ == '__main__':
    main()
