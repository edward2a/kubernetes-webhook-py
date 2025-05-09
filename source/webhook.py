#!/usr/bin/env python3

import argparse
import falcon
import json
import ssl

from wsgiref.simple_server import make_server

class HealthHandler(object):

    def on_get(self, req, resp):
        """Return HTTP/204."""
        resp.status = falcon.HTTP_NO_CONTENT

class ValidatingWebhookHandler(object):

    def on_post(self, req, resp):
        """Process validation request and respond."""
        print(json.dumps(req.media, indent=2))
        resp.media = {
            'apiVersion': 'admission.k8s.io/v1',
            'kind': 'AdmissionReview',
            'response': {
              'allowed': True,
              'uid': req.media['request']['uid'],
              'status': {'message': 'default approval'}
            }
        }

    def on_get(self, req, resp):
        resp.media = {'msg': 'Hello, world!'}


def parse_args():
    p = argparse.ArgumentParser()

    p.add_argument('--bind-ip', default="0.0.0.0")
    p.add_argument('--bind-port', default=8443, type=int)
    p.add_argument('--tls-cert', default='/usr/local/k8s-webhook-py/cert.pem')
    p.add_argument('--tls-key', default='/usr/local/k8s-webhook-py/key.pem')

    return p.parse_args()

def main():

    args = parse_args()

    app = falcon.App()
    app.add_route('/health', HealthHandler())
    app.add_route('/validate', ValidatingWebhookHandler())

    with make_server(args.bind_ip, args.bind_port, app) as httpd:
        ctx = ssl.create_default_context(purpose=ssl.Purpose.CLIENT_AUTH)
        ctx.load_cert_chain(args.tls_cert, args.tls_key)
        ctx.check_hostname = False
        ctx.verify_mode = ssl.CERT_NONE
        print('INFO: Starting server...')
        httpd.socket = ctx.wrap_socket(
            httpd.socket,
            server_side=True)
        httpd.serve_forever()

if __name__ == '__main__':
    main()
