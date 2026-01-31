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
    rev = "8c73b19ca906981be2227ba41b303e819ff59fc5";
    
    sha256 = "00byp3dgshwfa47c4mq210r5vlqkylpyk02dlwhjns70k671mfl9";
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
    rev = "6a8354f4b3af0c0f8988e4cfc2b8f6554182e6fc";
    
    sha256 = "0jd8rdb6rh7ji4dkdg0d09ihlacwnz5sa4kaqmgdq632f12s43m5";
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
    rev = "2383831533bf316ce0dea93205cd263c101452e9";
    
    sha256 = "00r7wmcl7fk900939cjc2dmnj2bbv8wjp19gdr500dali1v7mxk9";
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
    rev = "039d25dfcfb53b60c641b46fd471c45acc2811e0";
    
    sha256 = "00c3mjd223r6x0a8jzdz3j6qrrdixq8r5qyngn4nds1rg0k9vhxw";
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
    rev = "4defc51c0d5b35d5c503338fe79755436ccfb0e6";
    
    sha256 = "1xv198sn5i3k16f9k7irmnyjqz9jjl1n1w1flhjg3r938q17qna7";
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
    rev = "d42b3ba3c43ecd3a94467b29f48ae61901d2bebf";
    
    sha256 = "1xcnblj6g4snjdbza1vsw4xz9w7qiqa4sjlbh3r6hm3mp3iwza2m";
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
    rev = "455b6499f4eda64a7fd5391ebaf9c699d7270dcd";
    
    sha256 = "0731ipsnwdzi4wbsl9zy0vbc46iqyh5f4vfpnj6xb8k0sms52jz2";
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
    rev = "24536125a427eeca1180b9e37e86482e872393ee";
    
    sha256 = "06i3lr9yna72xngj8zrkicvn3lfhh73lyqr0ij2qni542d5vim8f";
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
    rev = "e60a1caef6ba8f78d8a28310c797ae0c569c014d";
    
    sha256 = "0pk8zc6a449r7zflnik14172vbvsa747z66hai43f6sbpz7a47rg";
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
    rev = "07aad061ee24502b2bdb4695c1e594b00818d90f";
    
    sha256 = "04cbc75bcib1imknw0cmva9awz73nay3mx73vd8msni5q6xdkrn4";
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
    rev = "6d1bdcbb38fb0358495f404e8cad38231498f1bf";
    
    sha256 = "05q2vff5z7ms8vv14l1z690gncmapjc5wxffzsq4vfd2cpbg4ig6";
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
    rev = "ad022fe03631d74be151e91ececb9698c55465a8";
    
    sha256 = "0bdwrkadk26vb9c14qrmkkcil5ddq8vyhb3wpm1isxax0fwkhbh2";
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
    rev = "e36668c887ffd349ca52553254476d1c52a5388b";
    
    sha256 = "0nv3nfd2rzw060w3xvlyq035kizj2pmprwk5kx4a9whq3qfaq1s3";
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
    rev = "adb44f2e032755b227b95c089c1d64c026809e18";
    
    sha256 = "08bn1j9xvkmj9k1js85wrgj535fp8f29drx574ldlhsdgmicnpd8";
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
    rev = "07e146b60c147bdfc7a4a1f07f044808078fc4a0";
    
    sha256 = "0dd09x76fffdijgqp4pcdy9s5hvir2xfkz30hgxh6wz56dj0pxlq";
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
    rev = "bb3016b84666f707899c36b679c145902510ea1f";
    
    sha256 = "1wyn07lbbjxhxv9367gg784jr881jmsdnz1rig9abfhj2p2dn28i";
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
    rev = "c13754571eb37e157fa5dc9d21651dc29827459d";
    
    sha256 = "03cv9sgxcxmrlk4h4mb072aq4ds44pds07hlh72lrbrp4kjaa7nh";
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
    rev = "4eb5517830ae58ca522bfe9f90abac1753579889";
    
    sha256 = "1y44rivch5zci1501nazyldy7qkf1n547245y2yy6ikah7s04x9j";
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
    rev = "55ecc70c85986dd7d692a42284a96f977ff732b6";
    
    sha256 = "10j35q04ma464glxlmh7pvlnk1ysnk71kvda4k9a5hvd4sfmns36";
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
    rev = "b2e044225ba078a892e80405f424f25f9518417b";
    
    sha256 = "1mm6lfnrji5gxlsa591gswcjdn5wh3g48f84d7n6lh42g5ibb3ks";
    crates = [
      {
        name = "proxmox-network-types";
        path = "proxmox-network-types";
      }
    ];
  }
  {
    name = "librust-proxmox-notify-dev";
    url = "git://git.proxmox.com/git/proxmox.git";
    rev = "52b04982627911d4d7255bd25c78d7eb4d695bcf";
    
    sha256 = "1xaamw59agm1dcphz2hpl46x8xpavl8vjjnjzrkqzm67vh3zrshp";
    crates = [
      {
        name = "proxmox-notify";
        path = "proxmox-notify";
      }
    ];
  }
  {
    name = "librust-proxmox-oci-dev";
    url = "git://git.proxmox.com/git/proxmox.git";
    rev = "56e0f959d8d906d169b1302920e96ca644692628";
    
    sha256 = "0k8pywhnnpz67k9qaks68g57pdrn5vzw9aabzrni4ph435zarq72";
    crates = [
      {
        name = "proxmox-oci";
        path = "proxmox-oci";
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
    rev = "69d1fddb642a2a102095cfa10e41ef10abc8a5e6";
    
    sha256 = "1ag2j6rb89321wps1isxjnyj8hr45hxrgx1jh84k19kj8322vrfb";
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
    rev = "9c04287c6a38fb00e85aa00935279e8aeb68c993";
    
    sha256 = "0daip10frbg79ks453qlrj197lhg2j5351yrc2mg5jgn2jh79z3r";
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
    rev = "99c6d274aa41dd09d49bf9b6947df05c209ca8f9";
    
    sha256 = "0h9qhi6gc1gjm8i2w2faahw91y6aagnian54scp0mh1mwi195dry";
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
    rev = "1a4e322d59debc6ba7d748ccb43236ce43c41741";
    
    sha256 = "1nizs8bmsghldsfxrpg4m7iqjm2y2nm41q0pli7l8ranwm9fy870";
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
    rev = "ed34cf12938cf9f78162ba5a2d98956b416a8883";
    
    sha256 = "0qk5jzlp8ks9gpaya88hs1v7slrhswxbwd023kkc8wg92bb1g7ir";
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
    rev = "17af874c77f767323a0cf19ef1345f9910ccb5ff";
    
    sha256 = "187g9sy767qh8hzmj3ydcys5b3i2di2dnbvrpkzm0h0g3xskk2q0";
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
    rev = "2a375fa97ea361fb7b2c283b754478a1a6e791c7";
    
    sha256 = "1f3rlcf8w0zfdn3znah79k3f55rqjvrg2k0w02klsr7knqv8s050";
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
    rev = "13340ae4452f8e07d2b35769233914ab8cb84192";
    
    sha256 = "1yafbqafwv7bjgc414p6vm6hiy0fwb53sh9wsp2l3m83i5ixx464";
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
    rev = "84ee8f4e5d825625a3d957b341f5c55cca1e4b32";
    
    sha256 = "06ygg8j5h466k0hvbbf0323abjcv7j72qxn2vkvfxxb7dygagwsd";
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
    rev = "35587a12af4197fb8243c9239a27302d2fc283b8";
    
    sha256 = "1f81702jxdi9mxbrix4fsq71aw5nmj41myi6y45cimx1lm49gpdg";
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
    rev = "7c2a07e69b42b73e149489027409932af623ef94";
    
    sha256 = "1mkm2wvpr7nn03b9f2kxlylwi2sf8nyynk3kjy10aam8x1kdnxa7";
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
    rev = "7440ea15b3a70fe4b00a4986957dfd031053ac14";
    
    sha256 = "08ysn6z0cfcic9w0xcpm9a590ry4dd60n3gs2c9nj5n81gz06rr8";
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
    rev = "320f2f0c600b03829bfe534ea4bed4730122dad0";
    
    sha256 = "01dnv4jcagpv8vkajm98l1bml3z8w5sj2p214y94l4915j7991xm";
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
    rev = "3db314886689109607ff9756fff04c4710e2c410";
    
    sha256 = "072f7b3pabkkhf7v349n2ns99xhqlamzs7wvhipgbz354rv62q42";
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
    
    sha256 = "00bnj6np9c7fqkn36qh3a902rzw08n8mc72i6q1pwcw7ywp7nxkk";
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
    rev = "4f236d3ce6aa882158bfc01a5cf86d87632542df";
    
    sha256 = "1py4rr61rrpmavphhibc7nq6764kiy4q9cns0s38sjgrfd9fphfw";
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
    rev = "f967b2341685536a53463137ad7c027ebc68e3e8";
    
    sha256 = "0z623af4xjczxpkxgblzr95rmgfn2b8cg22kc4vvccdhh5qbfmlz";
    crates = [
      {
        name = "proxmox-yew-comp";
        path = ".";
      }
    ];
  }
  {
    name = "librust-pve-api-types-dev";
    url = "git://git.proxmox.com/git/proxmox.git";
    rev = "162d6095dda6e49a84ff205ad088b8a02a970a85";
    
    sha256 = "0khrp58wcn3bchf3v5mh56pc5zh4rprqad7xf48rqdm4x864jw15";
    crates = [
      {
        name = "pve-api-types";
        path = "pve-api-types";
      }
    ];
  }
  {
    name = "librust-pwt-dev";
    url = "git://git.proxmox.com/git/ui/proxmox-yew-widget-toolkit.git";
    rev = "d6ed68117198ca602f75d5f72744c5c069a666ba";
    
    sha256 = "1nzxxhc02l8wxlanz2ik1d9v26w5ynad7s31vimzd0w299qjw9cg";
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
    rev = "23d4a1627b2cd89e97cba561a0824a2891b41452";
    
    sha256 = "0zjzh1iclb6gcidn5csxbbgdsz84s9mdgr4bv636ppchfa5j2vjv";
    crates = [
      {
        name = "pwt-macros";
        path = "pwt-macros";
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
