import * as forge from 'node-forge';

const PUB_HEADER = "-----BEGIN NEIGHBOR_NEWS PUBLIC KEY-----";
const PUB_FOOTER = "-----END NEIGHBOR_NEWS PUBLIC KEY-----";

const PRIV_HEADER = "-----BEGIN NEIGHBOR_NEWS PRIVATE KEY-----";
const PRIV_FOOTER = "-----END NEIGHBOR_NEWS PRIVATE KEY-----";

export const KeysService = {

  generateKeyPair: () => {
    const { publicKey, privateKey } = forge.pki.rsa.generateKeyPair({ bits: 2048, e: 0x10001 });
    return { publicKey, privateKey };
  },

  exportPublicKey: (publicKey: forge.pki.rsa.PublicKey): string => {
    const modulus = publicKey.n.toString(10);
    const exponent = publicKey.e.toString(10);

    const rawString = `${modulus}|${exponent}`;
    const base64Key = Buffer.from(rawString, 'utf8').toString('base64');
    return `${PUB_HEADER}\n${base64Key}\n${PUB_FOOTER}`;
  },

  exportPrivateKey: (privateKey: forge.pki.rsa.PrivateKey): string => {
    const modulus = privateKey.n.toString(10);
    const privateExponent = privateKey.d.toString(10);

    const rawString = `${modulus}|${privateExponent}`;
    const base64Key = Buffer.from(rawString, 'utf8').toString('base64');
    return `${PRIV_HEADER}\n${base64Key}\n${PRIV_FOOTER}`;
  },

  importPublicKey: (pemString: string): forge.pki.rsa.PublicKey => {
    if (!pemString.includes(PUB_HEADER) || !pemString.includes(PUB_FOOTER)) {
      throw new Error("Invalid key");
    }

    const base64Content = pemString
      .replace(PUB_HEADER, "")
      .replace(PUB_FOOTER, "")
      .replace(/\n/g, "")
      .trim();

    const rawString = Buffer.from(base64Content, 'base64').toString('utf8');
    const parts = rawString.split('|');
    const modulus = parts[0];
    const exponent = parts[1];

    const n = new forge.jsbn.BigInteger(modulus, 10);
    const e = new forge.jsbn.BigInteger(exponent, 10);

    return forge.pki.rsa.setPublicKey(n, e);
  },

  importPrivateKey: (pemString: string): forge.pki.rsa.PrivateKey => {
    if (!pemString.includes(PRIV_HEADER) || !pemString.includes(PRIV_FOOTER)) {
      throw new Error("Invalid key");
    }

    const base64Content = pemString
      .replace(PRIV_HEADER, "")
      .replace(PRIV_FOOTER, "")
      .replace(/\n/g, "")
      .trim();

    const rawString = Buffer.from(base64Content, 'base64').toString('utf8');
    const parts = rawString.split('|');
    const modulus = parts[0];
    const privateExponent = parts[1];

    const n = new forge.jsbn.BigInteger(modulus, 10);
    const d = new forge.jsbn.BigInteger(privateExponent, 10);
    const e = new forge.jsbn.BigInteger('65537', 10);

    // @ts-ignore
    return forge.pki.rsa.setPrivateKey(n, e, d);
  },

  toSign: (payload: string, privateKey: forge.pki.rsa.PrivateKey): string => {
    const md = forge.md.sha256.create();
    md.update(payload, 'utf8');
    const signature = privateKey.sign(md);
    return forge.util.encode64(signature);
  },

  toCheck: (payload: string, signature: string, publicKey: forge.pki.rsa.PublicKey): boolean => {
    try {
      const decodedSignature = forge.util.decode64(signature);
      const md = forge.md.sha256.create();
      md.update(payload, 'utf8');
      return publicKey.verify(md.digest().bytes(), decodedSignature);
    } catch (e) {
      return false;
    }
  }
};
