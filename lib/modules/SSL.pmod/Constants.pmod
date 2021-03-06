#pike __REAL_VERSION__

/*
 * The SSL3 Protocol is specified in the following RFCs and drafts:
 *
 *   SSL 3.0			draft-freier-ssl-version3-02.txt
 *   SSL 3.0			RFC 6101
 *
 *   SSL 3.1/TLS 1.0		RFC 2246
 *   Kerberos for TLS 1.0	RFC 2712
 *   AES Ciphers for TLS 1.0	RFC 3268
 *   Extensions for TLS 1.0	RFC 3546
 *   LZS Compression for TLS	RFC 3943
 *   Camellia Cipher for TLS	RFC 4132
 *   SEED Cipher for TLS 1.0	RFC 4162
 *   Pre-Shared Keys for TLS	RFC 4279
 *
 *   SSL 3.2/TLS 1.1		RFC 4346
 *   Extensions for TLS 1.1	RFC 4366
 *   ECC Ciphers for TLS 1.1	RFC 4492
 *   Session Resumption		RFC 4507
 *   TLS Handshake Message	RFC 4680
 *   User Mapping Extension	RFC 4681
 *   PSK with NULL for TLS 1.1	RFC 4785
 *   SRP with TLS 1.1		RFC 5054
 *   Session Resumption		RFC 5077
 *   OpenPGP Authentication	RFC 5081
 *   Authenticated Encryption	RFC 5116
 *
 *   DTLS over DCCP		RFC 5238
 *
 *   SSL 3.3/TLS 1.2		RFC 5246
 *   AES GCM Cipher for TLS	RFC 5288
 *   ECC with SHA256/384 & GCM	RFC 5289
 *   Suite B Profile for TLS	RFC 5430
 *   DES and IDEA for TLS	RFC 5469
 *   Pre-Shared Keys with GCM	RFC 5487
 *   ECDHA_PSK Cipher for TLS	RFC 5489
 *   Renegotiation Extension	RFC 5746
 *   Authorization Extensions	RFC 5878
 *   Camellia Cipher for TLS	RFC 5932
 *   KeyNote Auth for TLS	RFC 6042
 *   TLS Extension Defintions	RFC 6066
 *   OpenPGP Authentication	RFC 6091
 *   ARIA Cipher for TLS	RFC 6209
 *   Additional Master Secrets	RFC 6358
 *   Camellia Cipher for TLS	RFC 6367
 *   Suite B Profile for TLS	RFC 6460
 *   Heartbeat Extension	RFC 6520
 *   AES-CCM Cipher for TLS	RFC 6655
 *   Multiple Certificates	RFC 6961
 *   Certificate Transparency	RFC 6962
 *   ECC Brainpool Curves	RFC 7027
 *
 *   Next Protocol Negotiation  Google technical note: nextprotoneg
 *   Application Layer Protocol Negotiation  draft-ietf-tls-applayerprotoneg
 *
 * The SSL 2.0 protocol was specified in the following document:
 *
 *   SSL 2.0			draft-hickman-netscape-ssl-00.txt
 */

//! Protocol constants

//! Constants for specifying the versions of SSL to use.
//!
//! @seealso
//!   @[SSL.sslfile()->create()], @[SSL.handshake()->create()]
enum ProtocolVersion {
  PROTOCOL_SSL_3_0	= 0,	//! SSL 3.0 - The original SSL3 draft version.
  PROTOCOL_SSL_3_1	= 1,	//! SSL 3.1 - The RFC 2246 version of SSL.
  PROTOCOL_TLS_1_0	= 1,	//! TLS 1.0 - The RFC 2246 version of TLS.
  PROTOCOL_SSL_3_2	= 2,	//! SSL 3.2 - The RFC 4346 version of SSL.
  PROTOCOL_TLS_1_1	= 2,	//! TLS 1.1 - The RFC 4346 version of TLS.
  PROTOCOL_SSL_3_3	= 3,	//! SSL 3.3 - The RFC 5246 version of SSL.
  PROTOCOL_TLS_1_2	= 3,	//! TLS 1.2 - The RFC 5246 version of TLS.
}

//! Max supported SSL version.
constant PROTOCOL_major = 3;
constant PROTOCOL_minor = PROTOCOL_TLS_1_2;

/* Packet types */
constant PACKET_change_cipher_spec = 20;
constant PACKET_alert              = 21;
constant PACKET_handshake          = 22;
constant PACKET_application_data   = 23;
constant PACKET_types = (< PACKET_change_cipher_spec,
			   PACKET_alert,
			   PACKET_handshake,
			   PACKET_application_data >);
constant PACKET_V2 = -1; /* Backwards compatibility */

constant PACKET_MAX_SIZE = 0x4000;

/* Cipher specification */
constant CIPHER_stream   = 0;
constant CIPHER_block    = 1;
constant CIPHER_aead     = 2;
constant CIPHER_types = (< CIPHER_stream, CIPHER_block, CIPHER_aead >);

constant CIPHER_null     = 0;
constant CIPHER_rc4_40   = 2;
constant CIPHER_rc2_40   = 3;
constant CIPHER_des40    = 6;
constant CIPHER_rc4      = 1;
constant CIPHER_des      = 4;
constant CIPHER_3des     = 5;
constant CIPHER_fortezza = 7;
constant CIPHER_idea	 = 8;
constant CIPHER_aes	 = 9;
constant CIPHER_aes256	 = 10;
constant CIPHER_camellia128 = 11;
constant CIPHER_camellia256 = 12;

//! Mapping from cipher algorithm to effective key length.
constant CIPHER_effective_keylengths = ([
  CIPHER_null:		0, 
  CIPHER_rc2_40:	16,	// A 64bit key in RC2 has strength ~34...
  CIPHER_rc4_40:	40,
  CIPHER_des40:		32,	// A 56bit key in DES has strength ~40...
  CIPHER_rc4:		128,
  CIPHER_des:		40,
  CIPHER_3des:		112,
  CIPHER_fortezza:	96,
  CIPHER_idea:		128,
  CIPHER_aes:		128,
  CIPHER_aes256:	256,
  CIPHER_camellia128:	128,
  CIPHER_camellia256:	256,
]);

//! Hash algorithms as per RFC 5246 7.4.1.4.1.
enum HashAlgorithm {
  HASH_none	= 0,
  HASH_md5	= 1,
  HASH_sha	= 2,
  HASH_sha224	= 3,
  HASH_sha256	= 4,
  HASH_sha384	= 5,
  HASH_sha512	= 6,
}

//! Cipher operation modes.
enum CipherModes {
  MODE_cbc	= 0,	//! CBC - Cipher Block Chaining mode.
  MODE_gcm	= 1,	//! GCM - Galois Cipher Mode.
}

//! Lookup from @[HashAlgorithm] to corresponding @[Crypto.Hash].
constant HASH_lookup = ([
#if constant(Crypto.SHA512)
  HASH_sha512: Crypto.SHA512,
#endif
#if constant(Crypto.SHA384)
  HASH_sha384: Crypto.SHA384,
#endif
  HASH_sha256: Crypto.SHA256,
#if constant(Crypto.SHA224)
  HASH_sha224: Crypto.SHA224,
#endif
  HASH_sha:    Crypto.SHA1,
  HASH_md5:    Crypto.MD5,
]);

//! Signature algorithms from TLS 1.2.
enum SignatureAlgorithm {
  SIGNATURE_anonymous	= 0,	//! No signature.
  SIGNATURE_rsa		= 1,	//! RSASSA PKCS1 v1.5 signature.
  SIGNATURE_dsa		= 2,	//! DSS signature.
  SIGNATURE_ecdsa	= 3,	//! ECDSA signature.
}

//! Key exchange methods.
enum KeyExchangeType {
  KE_null	= 0,	//! None.
  KE_rsa	= 1,	//! Rivest-Shamir-Adelman
  /* We ignore the distinction between dh_dss and dh_rsa for now. */
  KE_dh		= 2,	//! Diffie-Hellman
  KE_dhe_dss	= 3,	//! Diffie-Hellman DSS
  KE_dhe_rsa	= 4,	//! Diffie-Hellman RSA
  KE_dh_anon	= 5,	//! Diffie-Hellman Anonymous
  KE_dms	= 6,
  KE_fortezza	= 7,
}

//! Compression methods.
enum CompressionType {
  COMPRESSION_null = 0,		//! No compression.
  COMPRESSION_deflate = 1,	//! Deflate compression.
  COMPRESSION_lzs = 64,		//! LZS compression. RFC 3943
}

/* Alert messages */
constant ALERT_warning			= 1;
constant ALERT_fatal			= 2;
constant ALERT_levels = (< ALERT_warning, ALERT_fatal >);

constant ALERT_close_notify			= 0;	// SSL 3.0
constant ALERT_unexpected_message		= 10;	// SSL 3.0
constant ALERT_bad_record_mac			= 20;	// SSL 3.0
constant ALERT_decryption_failed		= 21;	// TLS 1.0
constant ALERT_record_overflow			= 22;	// TLS 1.0
constant ALERT_decompression_failure		= 30;	// SSL 3.0
constant ALERT_handshake_failure		= 40;	// SSL 3.0
constant ALERT_no_certificate			= 41;	// SSL 3.0
constant ALERT_bad_certificate			= 42;	// SSL 3.0
constant ALERT_unsupported_certificate		= 43;	// SSL 3.0
constant ALERT_certificate_revoked		= 44;	// SSL 3.0
constant ALERT_certificate_expired		= 45;	// SSL 3.0
constant ALERT_certificate_unknown		= 46;	// SSL 3.0
constant ALERT_illegal_parameter		= 47;	// SSL 3.0
constant ALERT_unknown_ca			= 48;	// TLS 1.0
constant ALERT_access_denied			= 49;	// TLS 1.0
constant ALERT_decode_error			= 50;	// TLS 1.0
constant ALERT_decrypt_error			= 51;	// TLS 1.0
constant ALERT_export_restriction_RESERVED	= 60;	// TLS 1.0
constant ALERT_protocol_version			= 70;	// TLS 1.0
constant ALERT_insufficient_security		= 71;	// TLS 1.0
constant ALERT_internal_error			= 80;	// TLS 1.0
constant ALERT_user_canceled			= 90;	// TLS 1.0
constant ALERT_no_renegotiation			= 100;	// TLS 1.0
constant ALERT_unsupported_extension		= 110;	// RFC 3546
constant ALERT_certificate_unobtainable		= 111;	// RFC 3546
constant ALERT_unrecognized_name		= 112;	// RFC 3546
constant ALERT_bad_certificate_status_response	= 113;	// RFC 3546
constant ALERT_bad_certificate_hash_value	= 114;	// RFC 3546
constant ALERT_unknown_psk_identity		= 115;
constant ALERT_no_application_protocol          = 120;  // draft-ietf-tls-applayerprotoneg
constant ALERT_descriptions = ([
  ALERT_close_notify: "Connection closed.",
  ALERT_unexpected_message: "An inappropriate message was received.",
  ALERT_bad_record_mac: "Incorrect MAC.",
  ALERT_decryption_failed: "Decryption failure.",
  ALERT_record_overflow: "Record overflow.",
  ALERT_decompression_failure: "Decompression failure.",
  ALERT_handshake_failure: "Handshake failure.",
  ALERT_no_certificate: "Certificate required.",
  ALERT_bad_certificate: "Bad certificate.",
  ALERT_unsupported_certificate: "Unsupported certificate.",
  ALERT_certificate_revoked: "Certificate revoked.",
  ALERT_certificate_expired: "Certificate expired.",
  ALERT_certificate_unknown: "Unknown certificate problem.",
  ALERT_illegal_parameter: "Illegal parameter.",
  ALERT_unknown_ca: "Unknown certification authority.",
  ALERT_access_denied: "Access denied.",
  ALERT_decode_error: "Decoding error.",
  ALERT_decrypt_error: "Decryption error.",
  ALERT_export_restriction_RESERVED: "Export restrictions apply.",
  ALERT_protocol_version: "Unsupported protocol.",
  ALERT_insufficient_security: "Insufficient security.",
  ALERT_internal_error: "Internal error.",
  ALERT_user_canceled: "User canceled.",
  ALERT_no_renegotiation: "Renegotiation not allowed.",
  ALERT_unsupported_extension: "Unsolicitaded extension.",
  ALERT_certificate_unobtainable: "Failed to obtain certificate.",
  ALERT_unrecognized_name: "Unrecognized host name.",
  ALERT_bad_certificate_status_response: "Bad certificate status response.",
  ALERT_bad_certificate_hash_value: "Invalid certificate signature.",
  // ALERT_unknown_psk_identity
  ALERT_no_application_protocol : "No compatible application layer protocol.",
]);
 			      
constant CONNECTION_client 	= 0;
constant CONNECTION_server 	= 1;
constant CONNECTION_client_auth = 2;

/* Cipher suites */
constant SSL_null_with_null_null 		= 0x0000;	// SSL 3.0
constant SSL_rsa_with_null_md5			= 0x0001;	// SSL 3.0
constant SSL_rsa_with_null_sha			= 0x0002;	// SSL 3.0
constant SSL_rsa_export_with_rc4_40_md5		= 0x0003;	// SSL 3.0
constant SSL_rsa_export_with_rc2_cbc_40_md5	= 0x0006;	// SSL 3.0
constant SSL_rsa_export_with_des40_cbc_sha	= 0x0008;	// SSL 3.0
constant SSL_dh_dss_export_with_des40_cbc_sha	= 0x000b;	// SSL 3.0
constant SSL_dh_rsa_export_with_des40_cbc_sha	= 0x000e;	// SSL 3.0
constant SSL_dhe_dss_export_with_des40_cbc_sha	= 0x0011;	// SSL 3.0
constant SSL_dhe_rsa_export_with_des40_cbc_sha	= 0x0014;	// SSL 3.0
constant SSL_dh_anon_export_with_rc4_40_md5	= 0x0017;	// SSL 3.0
constant SSL_dh_anon_export_with_des40_cbc_sha	= 0x0019;	// SSL 3.0
constant TLS_krb5_with_des_cbc_40_sha           = 0x0026;	// RFC 2712
constant TLS_krb5_with_rc2_cbc_40_sha           = 0x0027;	// RFC 2712
constant TLS_krb5_with_rc4_40_sha               = 0x0028;	// RFC 2712
constant TLS_krb5_with_des_cbc_40_md5           = 0x0029;	// RFC 2712
constant TLS_krb5_with_rc2_cbc_40_md5           = 0x002a;	// RFC 2712
constant TLS_krb5_with_rc4_40_md5               = 0x002b;	// RFC 2712
constant TLS_psk_with_null_sha                  = 0x002c;	// RFC 4785
constant TLS_dhe_psk_with_null_sha              = 0x002d;	// RFC 4785
constant TLS_rsa_psk_with_null_sha              = 0x002e;	// RFC 4785
constant TLS_rsa_with_null_sha256               = 0x003b;	// TLS 1.2
constant SSL_rsa_with_rc4_128_md5		= 0x0004;	// SSL 3.0
constant SSL_rsa_with_rc4_128_sha		= 0x0005;	// SSL 3.0
constant SSL_rsa_with_idea_cbc_sha		= 0x0007;	// SSL 3.0
constant SSL_rsa_with_des_cbc_sha		= 0x0009;	// SSL 3.0
constant SSL_rsa_with_3des_ede_cbc_sha		= 0x000a;	// SSL 3.0
constant SSL_dh_dss_with_des_cbc_sha		= 0x000c;	// SSL 3.0
constant SSL_dh_dss_with_3des_ede_cbc_sha	= 0x000d;	// SSL 3.0
constant SSL_dh_rsa_with_des_cbc_sha		= 0x000f;	// SSL 3.0
constant SSL_dh_rsa_with_3des_ede_cbc_sha	= 0x0010;	// SSL 3.0
constant SSL_dhe_dss_with_des_cbc_sha		= 0x0012;	// SSL 3.0
constant SSL_dhe_dss_with_3des_ede_cbc_sha	= 0x0013;	// SSL 3.0
constant SSL_dhe_rsa_with_des_cbc_sha		= 0x0015;	// SSL 3.0
constant SSL_dhe_rsa_with_3des_ede_cbc_sha	= 0x0016;	// SSL 3.0
constant SSL_dh_anon_with_rc4_128_md5		= 0x0018;	// SSL 3.0
constant SSL_dh_anon_with_des_cbc_sha		= 0x001a;	// SSL 3.0
constant SSL_dh_anon_with_3des_ede_cbc_sha	= 0x001b;	// SSL 3.0

/* SSLv3/TLS conflict */
/* constant SSL_fortezza_dms_with_null_sha		= 0x001c; */
/* constant SSL_fortezza_dms_with_fortezza_cbc_sha	= 0x001d; */
/* constant SSL_fortezza_dms_with_rc4_128_sha	= 0x001e; */

constant TLS_krb5_with_des_cbc_sha              = 0x001e;	// RFC 2712
constant TLS_krb5_with_3des_ede_cbc_sha         = 0x001f;	// RFC 2712
constant TLS_krb5_with_rc4_128_sha              = 0x0020;	// RFC 2712
constant TLS_krb5_with_idea_cbc_sha             = 0x0021;	// RFC 2712
constant TLS_krb5_with_des_cbc_md5              = 0x0022;	// RFC 2712
constant TLS_krb5_with_3des_ede_cbc_md5         = 0x0023;	// RFC 2712
constant TLS_krb5_with_rc4_128_md5              = 0x0024;	// RFC 2712
constant TLS_krb5_with_idea_cbc_md5             = 0x0025;	// RFC 2712
constant TLS_rsa_with_aes_128_cbc_sha           = 0x002f;	// RFC 3268
constant TLS_dh_dss_with_aes_128_cbc_sha        = 0x0030;	// RFC 3268
constant TLS_dh_rsa_with_aes_128_cbc_sha        = 0x0031;	// RFC 3268
constant TLS_dhe_dss_with_aes_128_cbc_sha       = 0x0032;	// RFC 3268
constant TLS_dhe_rsa_with_aes_128_cbc_sha       = 0x0033;	// RFC 3268
constant TLS_dh_anon_with_aes_128_cbc_sha       = 0x0034;	// RFC 3268
constant TLS_rsa_with_aes_256_cbc_sha           = 0x0035;	// RFC 3268
constant TLS_dh_dss_with_aes_256_cbc_sha        = 0x0036;	// RFC 3268
constant TLS_dh_rsa_with_aes_256_cbc_sha        = 0x0037;	// RFC 3268
constant TLS_dhe_dss_with_aes_256_cbc_sha       = 0x0038;	// RFC 3268
constant TLS_dhe_rsa_with_aes_256_cbc_sha       = 0x0039;	// RFC 3268
constant TLS_dh_anon_with_aes_256_cbc_sha       = 0x003a;	// RFC 3268
constant TLS_rsa_with_aes_128_cbc_sha256        = 0x003c;	// TLS 1.2
constant TLS_rsa_with_aes_256_cbc_sha256        = 0x003d;	// TLS 1.2
constant TLS_dh_dss_with_aes_128_cbc_sha256     = 0x003e;	// TLS 1.2
constant TLS_dh_rsa_with_aes_128_cbc_sha256     = 0x003f;	// TLS 1.2
constant TLS_dhe_dss_with_aes_128_cbc_sha256    = 0x0040;	// TLS 1.2
constant TLS_rsa_with_camellia_128_cbc_sha      = 0x0041;	// RFC 4132
constant TLS_dh_dss_with_camellia_128_cbc_sha   = 0x0042;	// RFC 4132
constant TLS_dh_rsa_with_camellia_128_cbc_sha   = 0x0043;	// RFC 4132
constant TLS_dhe_dss_with_camellia_128_cbc_sha  = 0x0044;	// RFC 4132
constant TLS_dhe_rsa_with_camellia_128_cbc_sha  = 0x0045;	// RFC 4132
constant TLS_dh_anon_with_camellia_128_cbc_sha  = 0x0046;	// RFC 4132

constant TLS_dhe_rsa_with_aes_128_cbc_sha256    = 0x0067;	// TLS 1.2
constant TLS_dh_dss_with_aes_256_cbc_sha256     = 0x0068;	// TLS 1.2
constant TLS_dh_rsa_with_aes_256_cbc_sha256     = 0x0069;	// TLS 1.2
constant TLS_dhe_dss_with_aes_256_cbc_sha256    = 0x006a;	// TLS 1.2
constant TLS_dhe_rsa_with_aes_256_cbc_sha256    = 0x006b;	// TLS 1.2
constant TLS_dh_anon_with_aes_128_cbc_sha256    = 0x006c;	// TLS 1.2
constant TLS_dh_anon_with_aes_256_cbc_sha256    = 0x006d;	// TLS 1.2

constant TLS_rsa_with_camellia_256_cbc_sha      = 0x0084;	// RFC 4132
constant TLS_dh_dss_with_camellia_256_cbc_sha   = 0x0085;	// RFC 4132
constant TLS_dh_rsa_with_camellia_256_cbc_sha   = 0x0086;	// RFC 4132
constant TLS_dhe_dss_with_camellia_256_cbc_sha  = 0x0087;	// RFC 4132
constant TLS_dhe_rsa_with_camellia_256_cbc_sha  = 0x0088;	// RFC 4132
constant TLS_dh_anon_with_camellia_256_cbc_sha  = 0x0089;	// RFC 4132
constant TLS_psk_with_rc4_128_sha               = 0x008a;	// RFC 4279
constant TLS_psk_with_3des_ede_cbc_sha          = 0x008b;	// RFC 4279
constant TLS_psk_with_aes_128_cbc_sha           = 0x008c;	// RFC 4279
constant TLS_psk_with_aes_256_cbc_sha           = 0x008d;	// RFC 4279
constant TLS_dhe_psk_with_rc4_128_sha           = 0x008e;	// RFC 4279
constant TLS_dhe_psk_with_3des_ede_cbc_sha      = 0x008f;	// RFC 4279
constant TLS_dhe_psk_with_aes_128_cbc_sha       = 0x0090;	// RFC 4279
constant TLS_dhe_psk_with_aes_256_cbc_sha       = 0x0091;	// RFC 4279
constant TLS_rsa_psk_with_rc4_128_sha           = 0x0092;	// RFC 4279
constant TLS_rsa_psk_with_3des_ede_cbc_sha      = 0x0093;	// RFC 4279
constant TLS_rsa_psk_with_aes_128_cbc_sha       = 0x0094;	// RFC 4279
constant TLS_rsa_psk_with_aes_256_cbc_sha       = 0x0095;	// RFC 4279
constant TLS_rsa_with_seed_cbc_sha              = 0x0096;	// RFC 4162
constant TLS_dh_dss_with_seed_cbc_sha           = 0x0097;	// RFC 4162
constant TLS_dh_rsa_with_seed_cbc_sha           = 0x0098;	// RFC 4162
constant TLS_dhe_dss_with_seed_cbc_sha          = 0x0099;	// RFC 4162
constant TLS_dhe_rsa_with_seed_cbc_sha          = 0x009a;	// RFC 4162
constant TLS_dh_anon_with_seed_cbc_sha          = 0x009b;	// RFC 4162
constant TLS_rsa_with_aes_128_gcm_sha256        = 0x009c;	// RFC 5288
constant TLS_rsa_with_aes_256_gcm_sha384        = 0x009d;	// RFC 5288
constant TLS_dhe_rsa_with_aes_128_gcm_sha256    = 0x009e;	// RFC 5288
constant TLS_dhe_rsa_with_aes_256_gcm_sha384    = 0x009f;	// RFC 5288
constant TLS_dh_rsa_with_aes_128_gcm_sha256     = 0x00a0;	// RFC 5288
constant TLS_dh_rsa_with_aes_256_gcm_sha384     = 0x00a1;	// RFC 5288
constant TLS_dhe_dss_with_aes_128_gcm_sha256    = 0x00a2;	// RFC 5288
constant TLS_dhe_dss_with_aes_256_gcm_sha384    = 0x00a3;	// RFC 5288
constant TLS_dh_dss_with_aes_128_gcm_sha256     = 0x00a4;	// RFC 5288
constant TLS_dh_dss_with_aes_256_gcm_sha384     = 0x00a5;	// RFC 5288
constant TLS_dh_anon_with_aes_128_gcm_sha256    = 0x00a6;	// RFC 5288
constant TLS_dh_anon_with_aes_256_gcm_sha384    = 0x00a7;	// RFC 5288
constant TLS_psk_with_aes_128_gcm_sha256        = 0x00a8;	// RFC 5487
constant TLS_psk_with_aes_256_gcm_sha384        = 0x00a9;	// RFC 5487
constant TLS_dhe_psk_with_aes_128_gcm_sha256    = 0x00aa;	// RFC 5487
constant TLS_dhe_psk_with_aes_256_gcm_sha384    = 0x00ab;	// RFC 5487
constant TLS_rsa_psk_with_aes_128_gcm_sha256    = 0x00ac;	// RFC 5487
constant TLS_rsa_psk_with_aes_256_gcm_sha384    = 0x00ad;	// RFC 5487
constant TLS_psk_with_aes_128_cbc_sha256        = 0x00ae;	// RFC 5487
constant TLS_psk_with_aes_256_cbc_sha384        = 0x00af;	// RFC 5487
constant TLS_psk_with_null_sha256               = 0x00b0;	// RFC 5487
constant TLS_psk_with_null_sha384               = 0x00b1;	// RFC 5487
constant TLS_dhe_psk_with_aes_128_cbc_sha256    = 0x00b2;	// RFC 5487
constant TLS_dhe_psk_with_aes_256_cbc_sha384    = 0x00b3;	// RFC 5487
constant TLS_dhe_psk_with_null_sha256           = 0x00b4;	// RFC 5487
constant TLS_dhe_psk_with_null_sha384           = 0x00b5;	// RFC 5487
constant TLS_rsa_psk_with_aes_128_cbc_sha256    = 0x00b6;	// RFC 5487
constant TLS_rsa_psk_with_aes_256_cbc_sha384    = 0x00b7;	// RFC 5487
constant TLS_rsa_psk_with_null_sha256           = 0x00b8;	// RFC 5487
constant TLS_rsa_psk_with_null_sha384           = 0x00b9;	// RFC 5487
constant TLS_rsa_with_camellia_128_cbc_sha256   = 0x00ba;	// RFC 5932
constant TLS_dh_dss_with_camellia_128_cbc_sha256= 0x00bb;	// RFC 5932
constant TLS_dh_rsa_with_camellia_128_cbc_sha256= 0x00bc;	// RFC 5932
constant TLS_dhe_dss_with_camellia_128_cbc_sha256= 0x00bd;	// RFC 5932
constant TLS_dhe_rsa_with_camellia_128_cbc_sha256= 0x00be;	// RFC 5932
constant TLS_dh_anon_with_camellia_128_cbc_sha256= 0x00bf;	// RFC 5932
constant TLS_rsa_with_camellia_256_cbc_sha256   = 0x00c0;	// RFC 5932
constant TLS_dh_dss_with_camellia_256_cbc_sha256= 0x00c1;	// RFC 5932
constant TLS_dh_rsa_with_camellia_256_cbc_sha256= 0x00c2;	// RFC 5932
constant TLS_dhe_dss_with_camellia_256_cbc_sha256= 0x00c3;	// RFC 5932
constant TLS_dhe_rsa_with_camellia_256_cbc_sha256= 0x00c4;	// RFC 5932
constant TLS_dh_anon_with_camellia_256_cbc_sha256= 0x00c5;	// RFC 5932

constant TLS_empty_renegotiation_info_scsv	= 0x00ff;	// RFC 5746

constant TLS_ecdh_ecdsa_with_null_sha           = 0xc001;	// RFC 4492
constant TLS_ecdh_ecdsa_with_rc4_128_sha        = 0xc002;	// RFC 4492
constant TLS_ecdh_ecdsa_with_3des_ede_cbc_sha   = 0xc003;	// RFC 4492
constant TLS_ecdh_ecdsa_with_aes_128_cbc_sha    = 0xc004;	// RFC 4492
constant TLS_ecdh_ecdsa_with_aes_256_cbc_sha    = 0xc005;	// RFC 4492
constant TLS_ecdhe_ecdsa_with_null_sha          = 0xc006;	// RFC 4492
constant TLS_ecdhe_ecdsa_with_rc4_128_sha       = 0xc007;	// RFC 4492
constant TLS_ecdhe_ecdsa_with_3des_ede_cbc_sha  = 0xc008;	// RFC 4492
constant TLS_ecdhe_ecdsa_with_aes_128_cbc_sha   = 0xc009;	// RFC 4492
constant TLS_ecdhe_ecdsa_with_aes_256_cbc_sha   = 0xc00a;	// RFC 4492
constant TLS_ecdh_rsa_with_null_sha             = 0xc00b;	// RFC 4492
constant TLS_ecdh_rsa_with_rc4_128_sha          = 0xc00c;	// RFC 4492
constant TLS_ecdh_rsa_with_3des_ede_cbc_sha     = 0xc00d;	// RFC 4492
constant TLS_ecdh_rsa_with_aes_128_cbc_sha      = 0xc00e;	// RFC 4492
constant TLS_ecdh_rsa_with_aes_256_cbc_sha      = 0xc00f;	// RFC 4492
constant TLS_ecdhe_rsa_with_null_sha            = 0xc010;	// RFC 4492
constant TLS_ecdhe_rsa_with_rc4_128_sha         = 0xc011;	// RFC 4492
constant TLS_ecdhe_rsa_with_3des_ede_cbc_sha    = 0xc012;	// RFC 4492
constant TLS_ecdhe_rsa_with_aes_128_cbc_sha     = 0xc013;	// RFC 4492
constant TLS_ecdhe_rsa_with_aes_256_cbc_sha     = 0xc014;	// RFC 4492
constant TLS_ecdh_anon_with_null_sha            = 0xc015;	// RFC 4492
constant TLS_ecdh_anon_with_rc4_128_sha         = 0xc016;	// RFC 4492
constant TLS_ecdh_anon_with_3des_ede_cbc_sha    = 0xc017;	// RFC 4492
constant TLS_ecdh_anon_with_aes_128_cbc_sha     = 0xc018;	// RFC 4492
constant TLS_ecdh_anon_with_aes_256_cbc_sha     = 0xc019;	// RFC 4492
constant TLS_srp_sha_with_3des_ede_cbc_sha      = 0xc01a;	// RFC 5054
constant TLS_srp_sha_rsa_with_3des_ede_cbc_sha  = 0xc01b;	// RFC 5054
constant TLS_srp_sha_dss_with_3des_ede_cbc_sha  = 0xc01c;	// RFC 5054
constant TLS_srp_sha_with_aes_128_cbc_sha       = 0xc01d;	// RFC 5054
constant TLS_srp_sha_rsa_with_aes_128_cbc_sha   = 0xc01e;	// RFC 5054
constant TLS_srp_sha_dss_with_aes_128_cbc_sha   = 0xc01f;	// RFC 5054
constant TLS_srp_sha_with_aes_256_cbc_sha       = 0xc020;	// RFC 5054
constant TLS_srp_sha_rsa_with_aes_256_cbc_sha   = 0xc021;	// RFC 5054
constant TLS_srp_sha_dss_with_aes_256_cbc_sha   = 0xc022;	// RFC 5054
constant TLS_ecdhe_ecdsa_with_aes_128_cbc_sha256= 0xc023;	// RFC 5289
constant TLS_ecdhe_ecdsa_with_aes_256_cbc_sha384= 0xc024;	// RFC 5289
constant TLS_ecdh_ecdsa_with_aes_128_cbc_sha256 = 0xc025;	// RFC 5289
constant TLS_ecdh_ecdsa_with_aes_256_cbc_sha384 = 0xc026;	// RFC 5289
constant TLS_ecdhe_rsa_with_aes_128_cbc_sha256  = 0xc027;	// RFC 5289
constant TLS_ecdhe_rsa_with_aes_256_cbc_sha384  = 0xc028;	// RFC 5289
constant TLS_ecdh_rsa_with_aes_128_cbc_sha256   = 0xc029;	// RFC 5289
constant TLS_ecdh_rsa_with_aes_256_cbc_sha384   = 0xc02a;	// RFC 5289
constant TLS_ecdhe_ecdsa_with_aes_128_gcm_sha256= 0xc02b;	// RFC 5289
constant TLS_ecdhe_ecdsa_with_aes_256_gcm_sha384= 0xc02c;	// RFC 5289
constant TLS_ecdh_ecdsa_with_aes_128_gcm_sha256 = 0xc02d;	// RFC 5289
constant TLS_ecdh_ecdsa_with_aes_256_gcm_sha384 = 0xc02e;	// RFC 5289
constant TLS_ecdhe_rsa_with_aes_128_gcm_sha256  = 0xc02f;	// RFC 5289
constant TLS_ecdhe_rsa_with_aes_256_gcm_sha384  = 0xc030;	// RFC 5289
constant TLS_ecdh_rsa_with_aes_128_gcm_sha256   = 0xc031;	// RFC 5289
constant TLS_ecdh_rsa_with_aes_256_gcm_sha384   = 0xc032;	// RFC 5289
constant TLS_ecdhe_psk_with_rc4_128_sha         = 0xc033;	// RFC 5489
constant TLS_ecdhe_psk_with_3des_ede_cbc_sha    = 0xc034;	// RFC 5489
constant TLS_ecdhe_psk_with_aes_128_cbc_sha     = 0xc035;	// RFC 5489
constant TLS_ecdhe_psk_with_aes_256_cbc_sha     = 0xc036;	// RFC 5489
constant TLS_ecdhe_psk_with_aes_128_cbc_sha256  = 0xc037;	// RFC 5489
constant TLS_ecdhe_psk_with_aes_256_cbc_sha384  = 0xc038;	// RFC 5489
constant TLS_ecdhe_psk_with_null_sha            = 0xc039;	// RFC 5489
constant TLS_ecdhe_psk_with_null_sha256         = 0xc03a;	// RFC 5489
constant TLS_ecdhe_psk_with_null_sha384         = 0xc03b;	// RFC 5489
constant TLS_rsa_with_aria_128_cbc_sha256       = 0xc03c;	// RFC 6209
constant TLS_rsa_with_aria_256_cbc_sha384       = 0xc03d;	// RFC 6209
constant TLS_dh_dss_with_aria_128_cbc_sha256    = 0xc03e;	// RFC 6209
constant TLS_dh_dss_with_aria_256_cbc_sha384    = 0xc03f;	// RFC 6209
constant TLS_dh_rsa_with_aria_128_cbc_sha256    = 0xc040;	// RFC 6209
constant TLS_dh_rsa_with_aria_256_cbc_sha384    = 0xc041;	// RFC 6209
constant TLS_dhe_dss_with_aria_128_cbc_sha256   = 0xc042;	// RFC 6209
constant TLS_dhe_dss_with_aria_256_cbc_sha384   = 0xc043;	// RFC 6209
constant TLS_dhe_rsa_with_aria_128_cbc_sha256   = 0xc044;	// RFC 6209
constant TLS_dhe_rsa_with_aria_256_cbc_sha384   = 0xc045;	// RFC 6209
constant TLS_dh_anon_with_aria_128_cbc_sha256   = 0xc046;	// RFC 6209
constant TLS_dh_anon_with_aria_256_cbc_sha384   = 0xc047;	// RFC 6209
constant TLS_ecdhe_ecdsa_with_aria_128_cbc_sha256= 0xc048;	// RFC 6209
constant TLS_ecdhe_ecdsa_with_aria_256_cbc_sha384= 0xc049;	// RFC 6209
constant TLS_ecdh_ecdsa_with_aria_128_cbc_sha256= 0xc04a;	// RFC 6209
constant TLS_ecdh_ecdsa_with_aria_256_cbc_sha384= 0xc04b;	// RFC 6209
constant TLS_ecdhe_rsa_with_aria_128_cbc_sha256 = 0xc04c;	// RFC 6209
constant TLS_ecdhe_rsa_with_aria_256_cbc_sha384 = 0xc04d;	// RFC 6209
constant TLS_ecdh_rsa_with_aria_128_cbc_sha256  = 0xc04e;	// RFC 6209
constant TLS_ecdh_rsa_with_aria_256_cbc_sha384  = 0xc04f;	// RFC 6209
constant TLS_rsa_with_aria_128_gcm_sha256       = 0xc050;	// RFC 6209
constant TLS_rsa_with_aria_256_gcm_sha384       = 0xc051;	// RFC 6209
constant TLS_dhe_rsa_with_aria_128_gcm_sha256   = 0xc052;	// RFC 6209
constant TLS_dhe_rsa_with_aria_256_gcm_sha384   = 0xc053;	// RFC 6209
constant TLS_dh_rsa_with_aria_128_gcm_sha256    = 0xc054;	// RFC 6209
constant TLS_dh_rsa_with_aria_256_gcm_sha384    = 0xc055;	// RFC 6209
constant TLS_dhe_dss_with_aria_128_gcm_sha256   = 0xc056;	// RFC 6209
constant TLS_dhe_dss_with_aria_256_gcm_sha384   = 0xc057;	// RFC 6209
constant TLS_dh_dss_with_aria_128_gcm_sha256    = 0xc058;	// RFC 6209
constant TLS_dh_dss_with_aria_256_gcm_sha384    = 0xc059;	// RFC 6209
constant TLS_dh_anon_with_aria_128_gcm_sha256   = 0xc05a;	// RFC 6209
constant TLS_dh_anon_with_aria_256_gcm_sha384   = 0xc05b;	// RFC 6209
constant TLS_ecdhe_ecdsa_with_aria_128_gcm_sha256= 0xc05c;	// RFC 6209
constant TLS_ecdhe_ecdsa_with_aria_256_gcm_sha384= 0xc05d;	// RFC 6209
constant TLS_ecdh_ecdsa_with_aria_128_gcm_sha256= 0xc05e;	// RFC 6209
constant TLS_ecdh_ecdsa_with_aria_256_gcm_sha384= 0xc05f;	// RFC 6209
constant TLS_ecdhe_rsa_with_aria_128_gcm_sha256 = 0xc060;	// RFC 6209
constant TLS_ecdhe_rsa_with_aria_256_gcm_sha384 = 0xc061;	// RFC 6209
constant TLS_ecdh_rsa_with_aria_128_gcm_sha256  = 0xc062;	// RFC 6209
constant TLS_ecdh_rsa_with_aria_256_gcm_sha384  = 0xc063;	// RFC 6209
constant TLS_psk_with_aria_128_cbc_sha256       = 0xc064;	// RFC 6209
constant TLS_psk_with_aria_256_cbc_sha384       = 0xc065;	// RFC 6209
constant TLS_dhe_psk_with_aria_128_cbc_sha256   = 0xc066;	// RFC 6209
constant TLS_dhe_psk_with_aria_256_cbc_sha384   = 0xc067;	// RFC 6209
constant TLS_rsa_psk_with_aria_128_cbc_sha256   = 0xc068;	// RFC 6209
constant TLS_rsa_psk_with_aria_256_cbc_sha384   = 0xc069;	// RFC 6209
constant TLS_psk_with_aria_128_gcm_sha256       = 0xc06a;	// RFC 6209
constant TLS_psk_with_aria_256_gcm_sha384       = 0xc06b;	// RFC 6209
constant TLS_dhe_psk_with_aria_128_gcm_sha256   = 0xc06c;	// RFC 6209
constant TLS_dhe_psk_with_aria_256_gcm_sha384   = 0xc06d;	// RFC 6209
constant TLS_rsa_psk_with_aria_128_gcm_sha256   = 0xc06e;	// RFC 6209
constant TLS_rsa_psk_with_aria_256_gcm_sha384   = 0xc06f;	// RFC 6209
constant TLS_ecdhe_psk_with_aria_128_cbc_sha256 = 0xc070;	// RFC 6209
constant TLS_ecdhe_psk_with_aria_256_cbc_sha384 = 0xc071;	// RFC 6209
constant TLS_ecdhe_ecdsa_with_camellia_128_cbc_sha256= 0xc072;	// RFC 6367
constant TLS_ecdhe_ecdsa_with_camellia_256_cbc_sha384= 0xc073;	// RFC 6367
constant TLS_ecdh_ecdsa_with_camellia_128_cbc_sha256 = 0xc074;	// RFC 6367
constant TLS_ecdh_ecdsa_with_camellia_256_cbc_sha384 = 0xc075;	// RFC 6367
constant TLS_ecdhe_rsa_with_camellia_128_cbc_sha256  = 0xc076;	// RFC 6367
constant TLS_ecdhe_rsa_with_camellia_256_cbc_sha384  = 0xc077;	// RFC 6367
constant TLS_ecdh_rsa_with_camellia_128_cbc_sha256   = 0xc078;	// RFC 6367
constant TLS_ecdh_rsa_with_camellia_256_cbc_sha384   = 0xc079;	// RFC 6367
constant TLS_rsa_with_camellia_128_gcm_sha256        = 0xc07a;	// RFC 6367
constant TLS_rsa_with_camellia_256_gcm_sha384        = 0xc07b;	// RFC 6367
constant TLS_dhe_rsa_with_camellia_128_gcm_sha256    = 0xc07c;	// RFC 6367
constant TLS_dhe_rsa_with_camellia_256_gcm_sha384    = 0xc07d;	// RFC 6367
constant TLS_dh_rsa_with_camellia_128_gcm_sha256     = 0xc07e;	// RFC 6367
constant TLS_dh_rsa_with_camellia_256_gcm_sha384     = 0xc07f;	// RFC 6367
constant TLS_dhe_dss_with_camellia_128_gcm_sha256    = 0xc080;	// RFC 6367
constant TLS_dhe_dss_with_camellia_256_gcm_sha384    = 0xc081;	// RFC 6367
constant TLS_dh_dss_with_camellia_128_gcm_sha256     = 0xc082;	// RFC 6367
constant TLS_dh_dss_with_camellia_256_gcm_sha384     = 0xc083;	// RFC 6367
constant TLS_dh_anon_with_camellia_128_gcm_sha256    = 0xc084;	// RFC 6367
constant TLS_dh_anon_with_camellia_256_gcm_sha384    = 0xc085;	// RFC 6367
constant TLS_ecdhe_ecdsa_with_camellia_128_gcm_sha256= 0xc086;	// RFC 6367
constant TLS_ecdhe_ecdsa_with_camellia_256_gcm_sha384= 0xc087;	// RFC 6367
constant TLS_ecdh_ecdsa_with_camellia_128_gcm_sha256 = 0xc088;	// RFC 6367
constant TLS_ecdh_ecdsa_with_camellia_256_gcm_sha384 = 0xc089;	// RFC 6367
constant TLS_ecdhe_rsa_with_camellia_128_gcm_sha256  = 0xc08a;	// RFC 6367
constant TLS_ecdhe_rsa_with_camellia_256_gcm_sha384  = 0xc08b;	// RFC 6367
constant TLS_ecdh_rsa_with_camellia_128_gcm_sha256   = 0xc08c;	// RFC 6367
constant TLS_ecdh_rsa_with_camellia_256_gcm_sha384   = 0xc08d;	// RFC 6367
constant TLS_psk_with_camellia_128_gcm_sha256        = 0xc08d;	// RFC 6367
constant TLS_psk_with_camellia_256_gcm_sha384        = 0xc08f;	// RFC 6367
constant TLS_dhe_psk_with_camellia_128_gcm_sha256    = 0xc090;	// RFC 6367
constant TLS_dhe_psk_with_camellia_256_gcm_sha384    = 0xc091;	// RFC 6367
constant TLS_rsa_psk_with_camellia_128_gcm_sha256    = 0xc092;	// RFC 6367
constant TLS_rsa_psk_with_camellia_256_gcm_sha384    = 0xc093;	// RFC 6367
constant TLS_psk_with_camellia_128_cbc_sha256        = 0xc094;	// RFC 6367
constant TLS_psk_with_camellia_256_cbc_sha384        = 0xc095;	// RFC 6367
constant TLS_dhe_psk_with_camellia_128_cbc_sha256    = 0xc096;	// RFC 6367
constant TLS_dhe_psk_with_camellia_256_cbc_sha384    = 0xc097;	// RFC 6367
constant TLS_rsa_psk_with_camellia_128_cbc_sha256    = 0xc098;	// RFC 6367
constant TLS_rsa_psk_with_camellia_256_cbc_sha384    = 0xc099;	// RFC 6367
constant TLS_ecdhe_psk_with_camellia_128_cbc_sha256  = 0xc09a;	// RFC 6367
constant TLS_ecdhe_psk_with_camellia_256_cbc_sha384  = 0xc09b;	// RFC 6367
constant TLS_rsa_with_aes_128_ccm		= 0xc09c;	// RFC 6655
constant TLS_rsa_with_aes_256_ccm		= 0xc09d;	// RFC 6655
constant TLS_dhe_rsa_with_aes_128_ccm		= 0xc09e;	// RFC 6655
constant TLS_dhe_rsa_with_aes_256_ccm		= 0xc09f;	// RFC 6655
constant TLS_rsa_with_aes_128_ccm_8		= 0xc0a0;	// RFC 6655
constant TLS_rsa_with_aes_256_ccm_8		= 0xc0a1;	// RFC 6655
constant TLS_dhe_rsa_with_aes_128_ccm_8		= 0xc0a2;	// RFC 6655
constant TLS_dhe_rsa_with_aes_256_ccm_8		= 0xc0a3;	// RFC 6655

// Constants from SSL 2.0.
// These may appear in HANDSHAKE_hello_v2 and
// are here for informational purposes.
constant SSL2_ck_rc4_128_with_md5		= 0x010080;
constant SSL2_ck_rc4_128_export40_with_md5	= 0x020080;
constant SSL2_ck_rc2_128_cbc_with_md5		= 0x030080;
constant SSL2_ck_rc2_128_cbc_export40_with_md5	= 0x040080;
constant SSL2_ck_idea_128_cbc_with_md5		= 0x050080;
constant SSL2_ck_des_64_cbc_with_md5		= 0x060040;
constant SSL2_ck_des_192_ede3_cbc_with_md5	= 0x0700c0;

#if 0
/* Methods for signing any server_key_exchange message (RFC 5246 7.4.1.4.1) */
constant SIGN_anon = 0;
constant SIGN_rsa = 1;
constant SIGN_dsa = 2;
constant SIGN_ecdsa = 3;

/* FIXME: Add SIGN-type element to table */
#endif

constant CIPHER_SUITES =
([
   // The following cipher suites are only intended for testing.
   SSL_null_with_null_null :    	({ 0, 0, 0 }),
   SSL_rsa_with_null_md5 :      	({ KE_rsa, 0, HASH_md5 }), 
   SSL_rsa_with_null_sha :      	({ KE_rsa, 0, HASH_sha }),

   // NB: The export suites are obsolete in TLS 1.1 and later.
   //     The RC4/40 suite is required for Netscape 4.05 Intl.
   SSL_rsa_export_with_rc2_cbc_40_md5 :	({ KE_rsa, CIPHER_rc2_40, HASH_md5 }),
   SSL_rsa_export_with_rc4_40_md5 :	({ KE_rsa, CIPHER_rc4_40, HASH_md5 }),
   SSL_dhe_dss_export_with_des40_cbc_sha :
      ({ KE_dhe_dss, CIPHER_des40, HASH_sha }),
   SSL_dhe_rsa_export_with_des40_cbc_sha :
      ({ KE_dhe_rsa, CIPHER_des40, HASH_sha }),
   SSL_rsa_export_with_des40_cbc_sha :  ({ KE_rsa, CIPHER_des40, HASH_sha }),

   // NB: The IDEA and DES suites are obsolete in TLS 1.2 and later.
   SSL_rsa_with_idea_cbc_sha :		({ KE_rsa, CIPHER_idea, HASH_sha }),
   SSL_rsa_with_des_cbc_sha :		({ KE_rsa, CIPHER_des, HASH_sha }),
   SSL_dhe_dss_with_des_cbc_sha :	({ KE_dhe_dss, CIPHER_des, HASH_sha }),
   SSL_dhe_rsa_with_des_cbc_sha :	({ KE_dhe_rsa, CIPHER_des, HASH_sha }),

   SSL_rsa_with_rc4_128_sha :		({ KE_rsa, CIPHER_rc4, HASH_sha }),
   SSL_rsa_with_rc4_128_md5 :		({ KE_rsa, CIPHER_rc4, HASH_md5 }),

   // Required by TLS 1.0 RFC 2246 9.
   SSL_dhe_dss_with_3des_ede_cbc_sha :	({ KE_dhe_dss, CIPHER_3des, HASH_sha }),

   // Required by TLS 1.1 RFC 4346 9.
   SSL_rsa_with_3des_ede_cbc_sha :	({ KE_rsa, CIPHER_3des, HASH_sha }),

   // Required by TLS 1.2 RFC 5246 9.
   TLS_rsa_with_aes_128_cbc_sha :	({ KE_rsa, CIPHER_aes, HASH_sha }),

   SSL_dhe_rsa_with_3des_ede_cbc_sha :	({ KE_dhe_rsa, CIPHER_3des, HASH_sha }),

   TLS_dhe_dss_with_aes_128_cbc_sha :	({ KE_dhe_dss, CIPHER_aes, HASH_sha }),
   TLS_dhe_rsa_with_aes_128_cbc_sha :	({ KE_dhe_rsa, CIPHER_aes, HASH_sha }),
   TLS_rsa_with_aes_256_cbc_sha :	({ KE_rsa, CIPHER_aes256, HASH_sha }),
   TLS_dhe_dss_with_aes_256_cbc_sha :	({ KE_dhe_dss, CIPHER_aes256, HASH_sha }),
   TLS_dhe_rsa_with_aes_256_cbc_sha :	({ KE_dhe_rsa, CIPHER_aes256, HASH_sha }),

   TLS_rsa_with_aes_128_cbc_sha256 :    ({ KE_rsa, CIPHER_aes, HASH_sha256 }),
   TLS_dhe_rsa_with_aes_128_cbc_sha256 : ({ KE_dhe_rsa, CIPHER_aes, HASH_sha256 }),
   TLS_dhe_dss_with_aes_128_cbc_sha256 : ({ KE_dhe_dss, CIPHER_aes, HASH_sha256 }),
   TLS_rsa_with_aes_256_cbc_sha256 :	({ KE_rsa, CIPHER_aes256, HASH_sha256 }),
   TLS_dhe_rsa_with_aes_256_cbc_sha256 : ({ KE_dhe_rsa, CIPHER_aes256, HASH_sha256 }),
   TLS_dhe_dss_with_aes_256_cbc_sha256 : ({ KE_dhe_dss, CIPHER_aes256, HASH_sha256 }),

#if constant(Crypto.Camellia)
   TLS_rsa_with_camellia_128_cbc_sha:	({ KE_rsa, CIPHER_camellia128, HASH_sha }),
   TLS_dhe_dss_with_camellia_128_cbc_sha: ({ KE_dhe_dss, CIPHER_camellia128, HASH_sha }),
   TLS_dhe_rsa_with_camellia_128_cbc_sha: ({ KE_dhe_rsa, CIPHER_camellia128, HASH_sha }),
   TLS_rsa_with_camellia_256_cbc_sha:	({ KE_rsa, CIPHER_camellia256, HASH_sha }),
   TLS_dhe_dss_with_camellia_256_cbc_sha: ({ KE_dhe_dss, CIPHER_camellia256, HASH_sha }),
   TLS_dhe_rsa_with_camellia_256_cbc_sha: ({ KE_dhe_rsa, CIPHER_camellia256, HASH_sha }),

   TLS_rsa_with_camellia_128_cbc_sha256:	({ KE_rsa, CIPHER_camellia128, HASH_sha256 }),
   TLS_dhe_dss_with_camellia_128_cbc_sha256: ({ KE_dhe_dss, CIPHER_camellia128, HASH_sha256 }),
   TLS_dhe_rsa_with_camellia_128_cbc_sha256: ({ KE_dhe_rsa, CIPHER_camellia128, HASH_sha256 }),
   TLS_rsa_with_camellia_256_cbc_sha256:	({ KE_rsa, CIPHER_camellia256, HASH_sha256 }),
   TLS_dhe_dss_with_camellia_256_cbc_sha256: ({ KE_dhe_dss, CIPHER_camellia256, HASH_sha256 }),
   TLS_dhe_rsa_with_camellia_256_cbc_sha256: ({ KE_dhe_rsa, CIPHER_camellia256, HASH_sha256 }),
#endif /* Crypto.Camellia */

#if constant(Crypto.GCM)
   TLS_rsa_with_aes_128_gcm_sha256:	({ KE_rsa, CIPHER_aes, HASH_sha256, MODE_gcm }),
   TLS_dhe_rsa_with_aes_128_gcm_sha256:	({ KE_dhe_rsa, CIPHER_aes, HASH_sha256, MODE_gcm }),
   TLS_dhe_dss_with_aes_128_gcm_sha256:	({ KE_dhe_dss, CIPHER_aes, HASH_sha256, MODE_gcm }),

   TLS_rsa_with_aes_256_gcm_sha384:	({ KE_rsa, CIPHER_aes256, HASH_sha384, MODE_gcm }),
   TLS_dhe_rsa_with_aes_256_gcm_sha384:	({ KE_dhe_rsa, CIPHER_aes256, HASH_sha384, MODE_gcm }),
   TLS_dhe_dss_with_aes_256_gcm_sha384:	({ KE_dhe_dss, CIPHER_aes256, HASH_sha384, MODE_gcm }),
#if constant(Crypto.Camellia)
   TLS_rsa_with_camellia_128_gcm_sha256:({ KE_rsa, CIPHER_camellia128, HASH_sha256, MODE_gcm }),
   TLS_rsa_with_camellia_256_gcm_sha384:({ KE_rsa, CIPHER_camellia256, HASH_sha384, MODE_gcm }),
   TLS_dhe_rsa_with_camellia_128_gcm_sha256:({ KE_dhe_rsa, CIPHER_camellia128, HASH_sha256, MODE_gcm }),
   TLS_dhe_rsa_with_camellia_256_gcm_sha384:({ KE_dhe_rsa, CIPHER_camellia256, HASH_sha384, MODE_gcm }),
   TLS_dhe_dss_with_camellia_128_gcm_sha256:({ KE_dhe_dss, CIPHER_camellia128, HASH_sha256, MODE_gcm }),
   TLS_dhe_dss_with_camellia_256_gcm_sha384:({ KE_dhe_dss, CIPHER_camellia256, HASH_sha384, MODE_gcm }),
#endif /* Crypto.Camellia */
#endif /* Crypto.GCM */
]);

constant HANDSHAKE_hello_v2		= -1; /* Backwards compatibility */
constant HANDSHAKE_hello_request	= 0;
constant HANDSHAKE_client_hello		= 1;
constant HANDSHAKE_server_hello		= 2;
constant HANDSHAKE_hello_verify_request = 3;
constant HANDSHAKE_NewSessionTicket     = 4;
constant HANDSHAKE_certificate		= 11;
constant HANDSHAKE_server_key_exchange	= 12;
constant HANDSHAKE_certificate_request	= 13;
constant HANDSHAKE_server_hello_done	= 14;
constant HANDSHAKE_certificate_verify	= 15;
constant HANDSHAKE_client_key_exchange	= 16;
constant HANDSHAKE_finished		= 20;
constant HANDSHAKE_cerificate_url       = 21;
constant HANDSHAKE_certificate_status   = 22;
constant HANDSHAKE_supplemental_data    = 23;
constant HANDSHAKE_next_protocol	= 67;	// draft-agl-tls-nextprotoneg

constant AUTHLEVEL_none		= 1;
constant AUTHLEVEL_ask		= 2;
constant AUTHLEVEL_require	= 3;

/* FIXME: CERT_* would be better names for these constants */
constant AUTH_rsa_sign		= 1;	// SSL 3.0
constant AUTH_dss_sign		= 2;	// SSL 3.0
constant AUTH_rsa_fixed_dh	= 3;	// SSL 3.0
constant AUTH_dss_fixed_dh	= 4;	// SSL 3.0
constant AUTH_rsa_ephemeral_dh	= 5;	// SSL 3.0
constant AUTH_dss_ephemeral_dh	= 6;	// SSL 3.0
constant AUTH_fortezza_kea	= 20;	// SSL 3.0
constant AUTH_fortezza_dms	= 20;
constant AUTH_ecdsa_sign        = 64;
constant AUTH_rsa_fixed_ecdh    = 65;
constant AUTH_ecdsa_fixed_ecdh  = 66;

constant EXTENSION_server_name			= 0;		// RFC 6066
constant EXTENSION_max_fragment_length		= 1;		// RFC 6066
constant EXTENSION_client_certificate_url	= 2;		// RFC 6066
constant EXTENSION_trusted_ca_keys		= 3;		// RFC 6066
constant EXTENSION_truncated_hmac		= 4;		// RFC 6066
constant EXTENSION_status_request		= 5;		// RFC 6066
constant EXTENSIONS_user_mapping                = 6;            // RFC 4681
constant EXTENSION_client_authz			= 7;		// RFC 5878
constant EXTENSION_server_authz			= 8;		// RFC 5878
constant EXTENSION_cert_type                    = 9;            // RFC 6091
constant EXTENSION_elliptic_curves              = 10;           // RFC 4492
constant EXTENSION_ec_point_formats             = 11;           // RFC 4492
constant EXTENSION_srp                          = 12;           // RFC 5054
constant EXTENSION_signature_algorithms		= 13;		// RFC 5246
constant EXTENSION_use_srtp                     = 14;           // RFC 5764
constant EXTENSION_heartbeat                    = 15;           // RFC 6520
constant EXTENSION_application_layer_protocol_negotiation = 16; // draft-ietf-tls-applayerprotoneg
constant EXTENSION_status_request_v2            = 17;           // RFC-ietf-tls-multiple-cert-status-extension-08
constant EXTENSION_signed_certificate_timestamp = 18;           // RFC 6962
constant EXTENSION_session_ticket_tls           = 35;           // RFC 4507
constant EXTENSION_renegotiation_info		= 0xff01;	// RFC 5746
constant EXTENSION_next_protocol_negotiation	= 13172;	// draft-agl-tls-nextprotoneg
constant EXTENSION_padding                      = 35655;        // Same as Firefox / Chromium NSS
