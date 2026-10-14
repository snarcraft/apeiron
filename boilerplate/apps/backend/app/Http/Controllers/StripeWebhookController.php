<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;

/**
 * Stripe webhooks — signature-verified, Cashier-free.
 *
 * The endpoint is registered by `scripts/bootstrap.mjs`, which
 * creates the webhook via the Stripe API and pushes the signing
 * secret to GitHub. Verify the signature, then react — billing
 * domain logic (invoices, subscriptions) extends the hook below.
 */
class StripeWebhookController extends Controller
{
    public function __invoke(Request $request)
    {
        if (!$this->verifySignature($request)) {
            return response()->json(['error' => 'invalid signature'], 400);
        }

        logger()->info('stripe webhook', ['type' => $request->json('type')]);

        return response()->noContent();
    }

    private function verifySignature(Request $request): bool
    {
        $secret = (string) config('services.stripe.webhook_secret');

        if ($secret === '') {
            return false;
        }

        if (!preg_match('/t=(\d+),v1=([a-f0-9]{64})/', $request->header('Stripe-Signature', ''), $m)) {
            return false;
        }

        $expected = hash_hmac('sha256', $m[1].'.'.$request->getContent(), $secret);

        return hash_equals($expected, $m[2]);
    }
}
