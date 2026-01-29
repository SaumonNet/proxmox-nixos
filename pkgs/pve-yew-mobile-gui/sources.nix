[
  {
    name = "librust-pathpatterns-dev";
    url = "git://git.proxmox.com/git/pathpatterns.git";
    rev = "42e5e96e30297da878a4d4b3a7fa52b65c1be0ab";

    sha256 = "0fq2ik07wwd291m1r7z37zajfml15gb1h3gm88my12pn1x723hak";
    crates = [
      {
        name = "pathpatterns";
        path = ".";
      }
    ];
  }
  {
    name = "librust-pbs-api-types-dev";
    url = "git://git.proxmox.com/git/proxmox.git";
    rev = "a3c70d5eb88db31924cd539e0d5f55e77d26af77";

    sha256 = "0lcvdnsa8dks8vv27d6bfk7vai0wnvf8qrc6k29y04xgmnbsz2p7";
    crates = [
      {
        name = "pbs-api-types";
        path = "pbs-api-types";
      }
    ];
  }
  {
    name = "librust-perlmod-dev";
    url = "git://git.proxmox.com/git/perlmod.git";
    rev = "3f0fcc1f1601bad6ccacd38796865a927d100cda";

    sha256 = "1q6zq05dq5awfy50mi6cj374g0lnvy1vi4x4w6sw2c7xphswrr5n";
    crates = [
      {
        name = "perlmod";
        path = "perlmod";
      }
    ];
  }
  {
    name = "librust-perlmod-macro-dev";
    url = "git://git.proxmox.com/git/perlmod.git";
    rev = "4f946ea4362a5bdbbb131aa71dc6e3b19cb02467";

    sha256 = "0rnyd6jhkxacclm342239cvz903fwxgnmy07lwvszyiy0f23im0z";
    crates = [
      {
        name = "perlmod-macro";
        path = "perlmod-macro";
      }
    ];
  }
  {
    name = "librust-proxmox-access-control-dev";
    url = "git://git.proxmox.com/git/proxmox.git";
    rev = "56c4deb6309c41ff5afa5765b112be967c653857";

    sha256 = "0jdy5c1p554zfl7qngha8cyax1mqpwvg1nqjqjy5bcx2cmysyhcs";
    crates = [
      {
        name = "proxmox-access-control";
        path = "proxmox-access-control";
      }
    ];
  }
  {
    name = "librust-proxmox-acme-api-dev";
    url = "git://git.proxmox.com/git/proxmox.git";
    rev = "beaadf89ea2b0de080ea99c52cbef04753498a06";

    sha256 = "01v9w2xcc1dijsdgngcngicjjrbm5irc9z011ap8mw37rkfdq7iz";
    crates = [
      {
        name = "proxmox-acme-api";
        path = "proxmox-acme-api";
      }
    ];
  }
  {
    name = "librust-proxmox-acme-dev";
    url = "git://git.proxmox.com/git/proxmox.git";
    rev = "e45bcd1cd1f10ce53578dba6db13a68d9fbbd8cf";

    sha256 = "14hr1ixbhnfqcby49rr7cimfj668nglxgiql9hs24j28xf5ha6lj";
    crates = [
      {
        name = "proxmox-acme";
        path = "proxmox-acme";
      }
    ];
  }
  {
    name = "librust-proxmox-api-macro-dev";
    url = "git://git.proxmox.com/git/proxmox.git";
    rev = "478d8b9e8cddf14cdbd5f0d24effe7e30ce3fb84";

    sha256 = "02yxyzx9wzaagifymjncidp3jdv5hxpzqcn8i6c3hj4npjbg26zc";
    crates = [
      {
        name = "proxmox-api-macro";
        path = "proxmox-api-macro";
      }
    ];
  }
  {
    name = "librust-proxmox-apt-api-types-dev";
    url = "git://git.proxmox.com/git/proxmox.git";
    rev = "e2305b8f8e610e713b5acb9d90f42a1423abf1d8";

    sha256 = "09ywa6fkk7x10sa3234p3zkbjvsj404a0pqwbq59f1pkn5sd3b59";
    crates = [
      {
        name = "proxmox-apt-api-types";
        path = "proxmox-apt-api-types";
      }
    ];
  }
  {
    name = "librust-proxmox-apt-dev";
    url = "git://git.proxmox.com/git/proxmox.git";
    rev = "db5b6d35dd163132eb7c497fe1d4b69a7ee7475c";

    sha256 = "14yiqwl33ankk5g7mhykfivgj3fdmarrr7jszs8zrrw519chj0ap";
    crates = [
      {
        name = "proxmox-apt";
        path = "proxmox-apt";
      }
    ];
  }
  {
    name = "librust-proxmox-async-dev";
    url = "git://git.proxmox.com/git/proxmox.git";
    rev = "9820e1ca7694c505b3cb9711f124026e0bb7ea4a";

    sha256 = "0inf0iqs8hhz4xanvin0131f8a7ypk4yvfbl3brg6gf2rn6p6rhr";
    crates = [
      {
        name = "proxmox-async";
        path = "proxmox-async";
      }
    ];
  }
  {
    name = "librust-proxmox-auth-api-dev";
    url = "git://git.proxmox.com/git/proxmox.git";
    rev = "e917155007a6a246144179e26bda0ebb9b0a426f";

    sha256 = "1gpszwa5wfilgf87zf1d0y6blw037c4j14dcg586l3z6rrnzmaip";
    crates = [
      {
        name = "proxmox-auth-api";
        path = "proxmox-auth-api";
      }
    ];
  }
  {
    name = "librust-proxmox-base64-dev";
    url = "git://git.proxmox.com/git/proxmox.git";
    rev = "a5015e9684f62f7dc4f28111dec8971dd33a40d4";

    sha256 = "0c3f1dcsh5zz9gq91a1772zxg16vfxpvjnpj0xzkkhl4k57dbryr";
    crates = [
      {
        name = "proxmox-base64";
        path = "proxmox-base64";
      }
    ];
  }
  {
    name = "librust-proxmox-borrow-dev";
    url = "git://git.proxmox.com/git/proxmox.git";
    rev = "82beb937ad4308848cb50ab619320d3b553060f9";

    sha256 = "1929f28nc5w0asigvrm44wa5i93wmkhyf4zbj754k5xzr14qg8cg";
    crates = [
      {
        name = "proxmox-borrow";
        path = "proxmox-borrow";
      }
    ];
  }
  {
    name = "librust-proxmox-client-dev";
    url = "git://git.proxmox.com/git/proxmox.git";
    rev = "2b21ed67474ac26b57964354445b2b39bdbf4157";

    sha256 = "0ajm4mdxq35rx13vadm3mq6l935nkyvnl5iq6gy4kykr1j718phq";
    crates = [
      {
        name = "proxmox-client";
        path = "proxmox-client";
      }
    ];
  }
  {
    name = "librust-proxmox-compression-dev";
    url = "git://git.proxmox.com/git/proxmox.git";
    rev = "47719bb5836d23cfebd7904e95e5bf6770d6db4f";

    sha256 = "1ryd3h7nxa7gia9z52ia985gia1dyvhclsjdh4adiyrikbgzccsz";
    crates = [
      {
        name = "proxmox-compression";
        path = "proxmox-compression";
      }
    ];
  }
  {
    name = "librust-proxmox-config-digest-dev";
    url = "git://git.proxmox.com/git/proxmox.git";
    rev = "04fa1610da66aa4a3782a28f7d79c1043d4b42ed";

    sha256 = "0nxpm806civ5qx33h1r8qdi6hcxr656pr52d6c3n5ymgknx1h3aj";
    crates = [
      {
        name = "proxmox-config-digest";
        path = "proxmox-config-digest";
      }
    ];
  }
  {
    name = "librust-proxmox-daemon-dev";
    url = "git://git.proxmox.com/git/proxmox.git";
    rev = "de88fc9a481042a1d10164687515f5496c13a762";

    sha256 = "1m0rkarpmk2yxl2xkc04adxj4fnz39s09kcqgbd081jh6sv90vq3";
    crates = [
      {
        name = "proxmox-daemon";
        path = "proxmox-daemon";
      }
    ];
  }
  {
    name = "librust-proxmox-dns-api-dev";
    url = "git://git.proxmox.com/git/proxmox.git";
    rev = "4ea106bee233a996afbc1ce2dff6179f4f13433a";

    sha256 = "08srksgqpx1lqx99npk40imd9s70bms4p3k445h8byxr6znb5rxn";
    crates = [
      {
        name = "proxmox-dns-api";
        path = "proxmox-dns-api";
      }
    ];
  }
  {
    name = "librust-proxmox-frr-dev";
    url = "git://git.proxmox.com/git/proxmox-ve-rs.git";
    rev = "05b8fc9e7d004e821c7907dc4897b475cf97ac66";

    sha256 = "1y46wpxdkk964h8magz3h4k51z8hqqydnb68316jaamk1jflj9cl";
    crates = [
      {
        name = "proxmox-frr";
        path = "proxmox-frr";
      }
    ];
  }
  {
    name = "librust-proxmox-http-dev";
    url = "git://git.proxmox.com/git/proxmox.git";
    rev = "e43876114c5ea1cdbd13456682d91b8a7be02d2b";

    sha256 = "1ms8q65ynj1daqcqv98ylck1a5ski431mlbm1iyns6s9yf1f8mkh";
    crates = [
      {
        name = "proxmox-http";
        path = "proxmox-http";
      }
    ];
  }
  {
    name = "librust-proxmox-http-error-dev";
    url = "git://git.proxmox.com/git/proxmox.git";
    rev = "c54d689db2328803d1c7944311e55bc83805a1fa";

    sha256 = "1q39jkgjbn4cd7crvdinpx3z60zz53xyk0rfv10vkp0h46xd8da8";
    crates = [
      {
        name = "proxmox-http-error";
        path = "proxmox-http-error";
      }
    ];
  }
  {
    name = "librust-proxmox-human-byte-dev";
    url = "git://git.proxmox.com/git/proxmox.git";
    rev = "000432028d39633918cc9ae9ced55b5dc5141564";

    sha256 = "0wsc0srrfkaljbb7gb8k0d2p1shrg5zpx415545y2sfc40a50fvm";
    crates = [
      {
        name = "proxmox-human-byte";
        path = "proxmox-human-byte";
      }
    ];
  }
  {
    name = "librust-proxmox-io-dev";
    url = "git://git.proxmox.com/git/proxmox.git";
    rev = "b04e04b13d835b64abd30e1baf5974023cfcc370";

    sha256 = "1dqi3aqp91ks5np9k4m70s05x57p7jnx63hlsy7871vs7yqvf7f3";
    crates = [
      {
        name = "proxmox-io";
        path = "proxmox-io";
      }
    ];
  }
  {
    name = "librust-proxmox-lang-dev";
    url = "git://git.proxmox.com/git/proxmox.git";
    rev = "11076aa817184c94536483fc16e0f653a68b5cf0";

    sha256 = "1xml4z38zf03p8md8g0zysyn92klpl93dpafsry4lwmnlripv19b";
    crates = [
      {
        name = "proxmox-lang";
        path = "proxmox-lang";
      }
    ];
  }
  {
    name = "librust-proxmox-ldap-dev";
    url = "git://git.proxmox.com/git/proxmox.git";
    rev = "3ccba3065a9165ae949eabbd5a3ae08cf018cef7";

    sha256 = "0gz43z36j89mkidsri0hw75y9l244pcf5lbamq44s6d8gdsniz4m";
    crates = [
      {
        name = "proxmox-ldap";
        path = "proxmox-ldap";
      }
    ];
  }
  {
    name = "librust-proxmox-log-dev";
    url = "git://git.proxmox.com/git/proxmox.git";
    rev = "4a70ad566609a893451220b2ba0d4451a893e93e";

    sha256 = "17sqf08w4qr3i0zpi5psfwlyv7vaxwj7kfa9ibfs0i1sqpzk3cvb";
    crates = [
      {
        name = "proxmox-log";
        path = "proxmox-log";
      }
    ];
  }
  {
    name = "librust-proxmox-login-dev";
    url = "git://git.proxmox.com/git/proxmox.git";
    rev = "d22a98772c2cea7c49d469255ae1ed2060a10e7d";

    sha256 = "1h8w4xbappq9cvjcgnmfra4snfs2l6323y5bzr7cvz4xi4wfx269";
    crates = [
      {
        name = "proxmox-login";
        path = "proxmox-login";
      }
    ];
  }
  {
    name = "librust-proxmox-metrics-dev";
    url = "git://git.proxmox.com/git/proxmox.git";
    rev = "c6830856f5558b5a812f47d659e817a5543c7976";

    sha256 = "0790rzjf12i07i7kiphc3llzj206hbq9argjp6bl1019hxf28ywh";
    crates = [
      {
        name = "proxmox-metrics";
        path = "proxmox-metrics";
      }
    ];
  }
  {
    name = "librust-proxmox-network-api-dev";
    url = "git://git.proxmox.com/git/proxmox.git";
    rev = "16588a7d07deedfe84433837ca90743e23c8ad3b";

    sha256 = "13rdix51vmsc31xhmgkjyy5x1jy5anr46p8kk779dcn6j01453b3";
    crates = [
      {
        name = "proxmox-network-api";
        path = "proxmox-network-api";
      }
    ];
  }
  {
    name = "librust-proxmox-network-types-dev";
    url = "git://git.proxmox.com/git/proxmox.git";
    rev = "ffe61b2cc31de6592be8129aadba5918dd9d4911";

    sha256 = "1gv3krnvdpjwl4gfgvdjvhrpxcdc5dwzdrvrjk3by0mmvlc9dp3f";
    crates = [
      {
        name = "proxmox-network-types";
        path = "proxmox-network-types";
      }
    ];
  }
  {
    name = "librust-proxmox-node-status-dev";
    url = "git://git.proxmox.com/git/proxmox.git";
    rev = "fe863e169e9c1a775a4065dd007ab9ceed4ce07b";

    sha256 = "1w24pmiqhxqbkafc2kwra0vnzrhjhrf1fw1b6vyqhljzhl3s16jy";
    crates = [
      {
        name = "proxmox-node-status";
        path = "proxmox-node-status";
      }
    ];
  }
  {
    name = "librust-proxmox-notify-dev";
    url = "git://git.proxmox.com/git/proxmox.git";
    rev = "43e3a6ca48e1352e2c20cf8616915a31a9ad8c10";

    sha256 = "0rn1jaymr50vgqpbbg604kgq03wqg7zjclx6g9ab5y7jb59av9i7";
    crates = [
      {
        name = "proxmox-notify";
        path = "proxmox-notify";
      }
    ];
  }
  {
    name = "librust-proxmox-openid-dev";
    url = "git://git.proxmox.com/git/proxmox.git";
    rev = "cddc6b525b92cea57694297fba678d49e348ba8a";

    sha256 = "1wkrs2xid9wfzv4i9r0kpcdrxhr8rhlp5hwyzbjvm2vi50h0d0jl";
    crates = [
      {
        name = "proxmox-openid";
        path = "proxmox-openid";
      }
    ];
  }
  {
    name = "librust-proxmox-product-config-dev";
    url = "git://git.proxmox.com/git/proxmox.git";
    rev = "d42d5038bc4998200d18c9d190b9b013d6522722";

    sha256 = "1dsjziab9d8lm34fdd4fh2rjm6xz3fas6rwaya0gzc8dwmvn4ar2";
    crates = [
      {
        name = "proxmox-product-config";
        path = "proxmox-product-config";
      }
    ];
  }
  {
    name = "librust-proxmox-resource-scheduling-dev";
    url = "git://git.proxmox.com/git/proxmox.git";
    rev = "5625354accdede10680287257d959e135b6742d0";

    sha256 = "02bh82r3yccvgydvpi23k8nh0r2wn3503ji0z35fl5npb7ayzvsk";
    crates = [
      {
        name = "proxmox-resource-scheduling";
        path = "proxmox-resource-scheduling";
      }
    ];
  }
  {
    name = "librust-proxmox-rest-server-dev";
    url = "git://git.proxmox.com/git/proxmox.git";
    rev = "03a7d59ac477f804c7acfbc1d4f4f8351715b852";

    sha256 = "1zhccvksqywdnqrjgjyhrbhrbbm13sv1yhkp6k3cxa1a0273a0sc";
    crates = [
      {
        name = "proxmox-rest-server";
        path = "proxmox-rest-server";
      }
    ];
  }
  {
    name = "librust-proxmox-router-dev";
    url = "git://git.proxmox.com/git/proxmox.git";
    rev = "35c28da99fc02a8f9de3e010ccac3dc8167e8c31";

    sha256 = "1a51xxz9l5gs02dyxhx1zcc1733j543n04xnx5557cxbyfcj5d9h";
    crates = [
      {
        name = "proxmox-router";
        path = "proxmox-router";
      }
    ];
  }
  {
    name = "librust-proxmox-s3-client-dev";
    url = "git://git.proxmox.com/git/proxmox.git";
    rev = "de54ac7f42817a66a9724e393d470a5730de5e72";

    sha256 = "0q6lambyhfbkr4yv61v1j4l5x61bb3lia2mh2rgc4l9fksnaxgg2";
    crates = [
      {
        name = "proxmox-s3-client";
        path = "proxmox-s3-client";
      }
    ];
  }
  {
    name = "librust-proxmox-schema-dev";
    url = "git://git.proxmox.com/git/proxmox.git";
    rev = "c404bcbe16f5b9bab5ddea06d2b1274fae0667c3";

    sha256 = "0h4c8i9aya8m429vadafjhvghv2lvphiwy4fypyd55lw02hi4cnb";
    crates = [
      {
        name = "proxmox-schema";
        path = "proxmox-schema";
      }
    ];
  }
  {
    name = "librust-proxmox-sdn-types-dev";
    url = "git://git.proxmox.com/git/proxmox-ve-rs.git";
    rev = "f662e9221b1705c1660ef14257c7c54fd10101ab";

    sha256 = "0v2mffg4wcjyppxanyxzvgsc4l90milivni4x31c8lhsb0k5gddc";
    crates = [
      {
        name = "proxmox-sdn-types";
        path = "proxmox-sdn-types";
      }
    ];
  }
  {
    name = "librust-proxmox-section-config-dev";
    url = "git://git.proxmox.com/git/proxmox.git";
    rev = "61b5788a639e3e74f85666f8c240d6b37acdf9fa";

    sha256 = "0w8zggdf9dcfbk8f11ipq50z0id9fab0jadsrjn8vw1w5gh5rwf9";
    crates = [
      {
        name = "proxmox-section-config";
        path = "proxmox-section-config";
      }
    ];
  }
  {
    name = "librust-proxmox-sendmail-dev";
    url = "git://git.proxmox.com/git/proxmox.git";
    rev = "f03e6651032acce45246f49a6bc6bc1f0794244b";

    sha256 = "098px04lajing8pypax7lqardafdzsm9ikpg8qdcwx7p1qhsnjvy";
    crates = [
      {
        name = "proxmox-sendmail";
        path = "proxmox-sendmail";
      }
    ];
  }
  {
    name = "librust-proxmox-serde-dev";
    url = "git://git.proxmox.com/git/proxmox.git";
    rev = "521ebf5bf0160f7a8843d363073ebb9e21d101c1";

    sha256 = "0mwsdg7j6xa1nlvgnqqlpw49vazs399f2m3c4g5p08hx39wvlhzv";
    crates = [
      {
        name = "proxmox-serde";
        path = "proxmox-serde";
      }
    ];
  }
  {
    name = "librust-proxmox-shared-cache-dev";
    url = "git://git.proxmox.com/git/proxmox.git";
    rev = "d23c49fe82b9bd7a15c7c58585be443116f3045a";

    sha256 = "151czqr9v08vqp2jfgdbc79fbq5v7jpyhifzn244zrvmklpgsmiv";
    crates = [
      {
        name = "proxmox-shared-cache";
        path = "proxmox-shared-cache";
      }
    ];
  }
  {
    name = "librust-proxmox-shared-memory-dev";
    url = "git://git.proxmox.com/git/proxmox.git";
    rev = "eb1116c1e3fd27e391a9dde487eabc673368a6c5";

    sha256 = "0gccrgy2qlggqwhb42zkypn8bdg05xxd62g4gaz9mzc1wby9bk34";
    crates = [
      {
        name = "proxmox-shared-memory";
        path = "proxmox-shared-memory";
      }
    ];
  }
  {
    name = "librust-proxmox-simple-config-dev";
    url = "git://git.proxmox.com/git/proxmox.git";
    rev = "c273e86e0cef266e11ccfe2d2522e79173ffdaff";

    sha256 = "1zma7rj7ksl0n5msnwbi195kkxchj3ax9h5fg3q8v5v70dmv8vv9";
    crates = [
      {
        name = "proxmox-simple-config";
        path = "proxmox-simple-config";
      }
    ];
  }
  {
    name = "librust-proxmox-sortable-macro-dev";
    url = "git://git.proxmox.com/git/proxmox.git";
    rev = "a1766995b589c5668a7f9d4f0b15e6fbe32b6a36";

    sha256 = "1p1q732ni8cmx3hckac01q93y1bq2qrpr0zgigwq095gg6xik680";
    crates = [
      {
        name = "proxmox-sortable-macro";
        path = "proxmox-sortable-macro";
      }
    ];
  }
  {
    name = "librust-proxmox-subscription-dev";
    url = "git://git.proxmox.com/git/proxmox.git";
    rev = "5f641e5a99e89d52ccdde500d79ce2c0d6dea71a";

    sha256 = "1s249m4z776czzbhi0s4a8vshh2p7pw305iqxfsjnk06ii6zghnf";
    crates = [
      {
        name = "proxmox-subscription";
        path = "proxmox-subscription";
      }
    ];
  }
  {
    name = "librust-proxmox-sys-dev";
    url = "git://git.proxmox.com/git/proxmox.git";
    rev = "4919e03d9bd2b6b0be914667eedcff81e727ab12";

    sha256 = "1990ywrlzd9jiliskcha96kmqbdlw6bcwixyjsdnm8kpnc8rrxzk";
    crates = [
      {
        name = "proxmox-sys";
        path = "proxmox-sys";
      }
    ];
  }
  {
    name = "librust-proxmox-syslog-api-dev";
    url = "git://git.proxmox.com/git/proxmox.git";
    rev = "b79913168ac606619b4934a614dcfc83cc6833ee";

    sha256 = "1q3z4csi2l2m1bppk9rv7hmf9mlwsvfa7a7c3iil0c9ws3767x0d";
    crates = [
      {
        name = "proxmox-syslog-api";
        path = "proxmox-syslog-api";
      }
    ];
  }
  {
    name = "librust-proxmox-systemd-dev";
    url = "git://git.proxmox.com/git/proxmox.git";
    rev = "fb3e8ca768c5c815fc55ca78e095df35a1c06d78";

    sha256 = "1lblv6sw4rrwf1xha3hz727mwas90zqykx9nwrw60s0sabw5pyic";
    crates = [
      {
        name = "proxmox-systemd";
        path = "proxmox-systemd";
      }
    ];
  }
  {
    name = "librust-proxmox-tfa-dev";
    url = "git://git.proxmox.com/git/proxmox.git";
    rev = "7de539b26cbca1bdc2a24f3591e59469d95746e1";

    sha256 = "0x4nvz5ysxh0s0dgf86salac086b25apsllgqisb379670wfn9gn";
    crates = [
      {
        name = "proxmox-tfa";
        path = "proxmox-tfa";
      }
    ];
  }
  {
    name = "librust-proxmox-time-api-dev";
    url = "git://git.proxmox.com/git/proxmox.git";
    rev = "3d8d38799e403e069679aa942565d95bc65b48fe";

    sha256 = "0ga8zp7kqvlzvjal9zgwi4qx7nj0grjg0a9xb9ll6anx08si0jac";
    crates = [
      {
        name = "proxmox-time-api";
        path = "proxmox-time-api";
      }
    ];
  }
  {
    name = "librust-proxmox-time-dev";
    url = "git://git.proxmox.com/git/proxmox.git";
    rev = "a79ccc19071ad69ee419a58f38577216182ffbaa";

    sha256 = "1kl0syqwf59654i43hm4ca0l124wixl43mlvhhj9p2j81iydyyzn";
    crates = [
      {
        name = "proxmox-time";
        path = "proxmox-time";
      }
    ];
  }
  {
    name = "librust-proxmox-uuid-dev";
    url = "git://git.proxmox.com/git/proxmox.git";
    rev = "391412712c4dd6f86157eb0c3767ef6e36750896";

    sha256 = "sha256-c3Z7LveHM34DNlEcVpFFgP8sQFIDYjPsxO6wdK2RdgE=";
    crates = [
      {
        name = "proxmox-uuid";
        path = "proxmox-uuid";
      }
    ];
  }
  {
    name = "librust-proxmox-ve-config-dev";
    url = "git://git.proxmox.com/git/proxmox-ve-rs.git";
    rev = "587c67fdb139463a5e6218dd17d1cd442babe9b5";

    sha256 = "1xdnkcya5xi09gddf5y197bz9mvyxz6crdrq4xhwqavc3p6bvwv1";
    crates = [
      {
        name = "proxmox-ve-config";
        path = "proxmox-ve-config";
      }
    ];
  }
  {
    name = "librust-proxmox-worker-task-dev";
    url = "git://git.proxmox.com/git/proxmox.git";
    rev = "b7292443a12b2f0c43b5d4e9bee6334e0e6241ff";

    sha256 = "1q0pvx1vrhpva2n7ykvpzgch735c7vhg5lvb4n6946l33dn0cyna";
    crates = [
      {
        name = "proxmox-worker-task";
        path = "proxmox-worker-task";
      }
    ];
  }
  {
    name = "librust-proxmox-yew-comp-dev";
    url = "git://git.proxmox.com/git/ui/proxmox-yew-comp.git";
    rev = "30676b69220b07351d6eef19c48f7822ee5af32c";

    sha256 = "1m2rjhycgakq6887r1s6nn80dz264qfpcqr5fdr8ipymwwqbqikd";
    crates = [
      {
        name = "proxmox-yew-comp";
        path = ".";
      }
    ];
  }
  {
    name = "librust-pwt-dev";
    url = "git://git.proxmox.com/git/ui/proxmox-yew-widget-toolkit.git";
    rev = "41d70cb7d845ca8f50634386c13972c973248fcb";

    sha256 = "025jxzj5q6mf6lqv22dya4lb48a1j3kik8jigsn4y3jf7l5x8x5q";
    crates = [
      {
        name = "pwt";
        path = ".";
      }
    ];
  }
  {
    name = "librust-pwt-macros-dev";
    url = "git://git.proxmox.com/git/ui/proxmox-yew-widget-toolkit.git";
    rev = "41d70cb7d845ca8f50634386c13972c973248fcb";

    sha256 = "025jxzj5q6mf6lqv22dya4lb48a1j3kik8jigsn4y3jf7l5x8x5q";
    crates = [
      {
        name = "pwt-macros";
        path = "pwt-macros";
      }
    ];
  }
  {
    name = "librust-pve-api-types-dev";
    url = "git://git.proxmox.com/git/proxmox.git";
    rev = "54299e63614cc570ff871af88091bb907225fd25";

    sha256 = "1fkhahp92p8nr1x25aqcwyhb3v4a8x08sr0vwh7sgkpxr9s7h3yz";
    crates = [
      {
        name = "pve-api-types";
        path = "pve-api-types";
      }
    ];
  }
  {
    name = "librust-pxar-dev";
    url = "git://git.proxmox.com/git/pxar.git";
    rev = "993c66fcb8819770f279cb9fb4d13f58f367606c";

    sha256 = "1bqfdq15kq45wrqmsh559ijbv48k73fjca5l4198mflgii6f942p";
    crates = [
      {
        name = "pxar";
        path = ".";
      }
    ];
  }
]
