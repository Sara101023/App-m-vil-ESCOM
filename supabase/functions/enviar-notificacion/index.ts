import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

const FIREBASE_PROJECT_ID = "ets-escom-1a7a6";

serve(async (req) => {
  try {
    const { fcm_token, titulo, cuerpo } = await req.json();

    if (!fcm_token) {
      return new Response(JSON.stringify({ error: "Token FCM requerido" }), {
        status: 400,
        headers: { "Content-Type": "application/json" },
      });
    }

    // Obtener access token de Firebase
    const serviceAccount = JSON.parse(
      Deno.env.get("FIREBASE_SERVICE_ACCOUNT") ?? "{}"
    );

    const now = Math.floor(Date.now() / 1000);
    const payload = {
      iss: serviceAccount.client_email,
      sub: serviceAccount.client_email,
      aud: "https://oauth2.googleapis.com/token",
      iat: now,
      exp: now + 3600,
      scope: "https://www.googleapis.com/auth/firebase.messaging",
    };

    // Crear JWT para autenticación con Firebase
    const header = btoa(JSON.stringify({ alg: "RS256", typ: "JWT" }));
    const body = btoa(JSON.stringify(payload));
    const signingInput = `${header}.${body}`;

    // Importar llave privada
    const privateKey = serviceAccount.private_key;
    const keyData = privateKey
      .replace("-----BEGIN PRIVATE KEY-----", "")
      .replace("-----END PRIVATE KEY-----", "")
      .replace(/\n/g, "");

    const binaryKey = Uint8Array.from(atob(keyData), (c) => c.charCodeAt(0));
    const cryptoKey = await crypto.subtle.importKey(
      "pkcs8",
      binaryKey,
      { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
      false,
      ["sign"]
    );

    const signature = await crypto.subtle.sign(
      "RSASSA-PKCS1-v1_5",
      cryptoKey,
      new TextEncoder().encode(signingInput)
    );

    const jwt = `${signingInput}.${btoa(
      String.fromCharCode(...new Uint8Array(signature))
    )}`;

    // Obtener access token
    const tokenResponse = await fetch("https://oauth2.googleapis.com/token", {
      method: "POST",
      headers: { "Content-Type": "application/x-www-form-urlencoded" },
      body: `grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=${jwt}`,
    });

    const tokenData = await tokenResponse.json();
    const accessToken = tokenData.access_token;

    // Enviar notificación FCM
    const fcmResponse = await fetch(
      `https://fcm.googleapis.com/v1/projects/${FIREBASE_PROJECT_ID}/messages:send`,
      {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${accessToken}`,
        },
        body: JSON.stringify({
          message: {
            token: fcm_token,
            notification: {
              title: titulo,
              body: cuerpo,
            },
            android: {
              priority: "high",
              notification: {
                sound: "default",
                channel_id: "ets_channel",
              },
            },
          },
        }),
      }
    );

    const fcmData = await fcmResponse.json();

    return new Response(JSON.stringify({ success: true, data: fcmData }), {
      status: 200,
      headers: { "Content-Type": "application/json" },
    });
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
      headers: { "Content-Type": "application/json" },
    });
  }
});