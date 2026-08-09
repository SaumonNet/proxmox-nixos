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
    rev = "068a3b32f7d89a32f8ae112bd1e10149c7d310d7";
    
    sha256 = "1qfw3yp0n87h86q5bfqmy2qfvbgc8axycam3jpa9imqpc904m7i1";
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
    rev = "72c3df3371ab15a0439b57b02242d23db3b4a07b";
    
    sha256 = "0w7ihh687b658pislgmxidyv2qs3wz0r97g9xf2xx4wljv218nmw";
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
    rev = "664689a4e74376f12396c3bd07ccbaaaf10cb95e";
    
    sha256 = "008rwg4nqngfllyk4g3v294z68pvq0ra6mavk7vx1g824pv4p8hw";
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
    rev = "09a1f4064e30287762aaa0e6dd7b632f14581ccd";
    
    sha256 = "1ddrk447g1v4cwk26aqmqfmmaa7bdjjy1m75xfplr0yh6r5g3f9l";
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
    rev = "b5551a10d79e4ecd44b512842113a2a341ce9927";
    
    sha256 = "0f9vk8jlaxy3dbcsjja9762ql97mlnbra7bjial38cqsph7kvdd5";
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
    rev = "555033c3a59b7d83147e9efad160e0dab09eb645";
    
    sha256 = "1xyig4dqa6yw9gf28lbgwrr91fvvcpznsd0rvbpir5igrjz7bkc9";
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
    rev = "43ebf2b351df1e8b974af67402991c7bbbbe7968";
    
    sha256 = "199pw87ji59d6waxwzab30xs8dz6ihb5danhnp4x0fjwkyksnafd";
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
    rev = "28d65ea6740b91ba4d1bb7fa538969d467a53f97";
    
    sha256 = "0x9q1kx57635jqpliyhkxrn80wfkx0g9kscaan5h26bs2dmvv9k0";
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
    rev = "0746104b1fa5af3e4fa08725563c4b4d69b67c9d";
    
    sha256 = "0rzrhgp5vn1rgz8r14h23pmzkj54glsxl2d267wm8vp7wz4a2p9a";
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
    name = "librust-proxmox-deb-version-dev";
    url = "git://git.proxmox.com/git/proxmox.git";
    rev = "54e81790fe55759c6f56e3f6280790b3d62d97c2";
    
    sha256 = "0davwv41slmajlz5jfqff3yw8bgpa2mnhb4h83j737yj8fldig93";
    crates = [
      {
        name = "proxmox-deb-version";
        path = "proxmox-deb-version";
      }
    ];
  }
  {
    name = "librust-proxmox-disks-dev";
    url = "git://git.proxmox.com/git/proxmox.git";
    rev = "29b095ab00eebbc7f8f2ce89b16d12fb565a7cce";
    
    sha256 = "10qwfrgz6w1bjzhzygakm1i04rval2pdpzw103lwgk7z6hn7p52i";
    crates = [
      {
        name = "proxmox-disks";
        path = "proxmox-disks";
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
    name = "librust-proxmox-docgen-dev";
    url = "git://git.proxmox.com/git/proxmox.git";
    rev = "86fd18094faac6dea37a50f678154bb16f8c5336";
    
    sha256 = "1bjd8181shhl402i9zihcfy24z6jswxxqp7vshbkckijm7s5hnls";
    crates = [
      {
        name = "proxmox-docgen";
        path = "proxmox-docgen";
      }
    ];
  }
  {
    name = "librust-proxmox-fixed-string-dev";
    url = "git://git.proxmox.com/git/proxmox.git";
    rev = "e53a6814c3b5e98ed546489c396a14572a680f0f";
    
    sha256 = "0nf6jmc8f8z42g4gi2q384nm3p9h1nr3syjknf08lph05x0m65ia";
    crates = [
      {
        name = "proxmox-fixed-string";
        path = "proxmox-fixed-string";
      }
    ];
  }
  {
    name = "librust-proxmox-frr-dev";
    url = "git://git.proxmox.com/git/proxmox-ve-rs.git";
    rev = "a258e4633f65a20a76d182cc0436443a95e332df";
    
    sha256 = "1aqhdqqd5sniayn3n3kvk8l10f59ilziyi09796sc94y05s53w3p";
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
    rev = "8a0047725e88ecf40bc12cd3637d2469bced0d30";
    
    sha256 = "0p3970lgvkxnga4v50sg0x5ifhmybrb7p4n6zsam6qdmc0q3rwsr";
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
    name = "librust-proxmox-ini-dev";
    url = "git://git.proxmox.com/git/proxmox.git";
    rev = "1f70f19a65d9a2e3c89d1bad8bab581f28f4e6dd";
    
    sha256 = "1mbxl1vnrsc7gcxxgjv4771dbq0ix8hfv06fhin6jya4zkcbbzwb";
    crates = [
      {
        name = "proxmox-ini";
        path = "proxmox-ini";
      }
    ];
  }
  {
    name = "librust-proxmox-installer-types-dev";
    url = "git://git.proxmox.com/git/proxmox.git";
    rev = "cc0db6ae88bc2d701cb1eaca7eb1ce38a551f4b9";
    
    sha256 = "02s7hwmgbwx3k6a0z3dpyi670cxyma5xawa6sygjrkcvmdqjshb1";
    crates = [
      {
        name = "proxmox-installer-types";
        path = "proxmox-installer-types";
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
    rev = "ff45a34a29a7e35bb6cde09cdaa1da49d2a5440d";
    
    sha256 = "0zn29gn15kv30q8vygq56xb3y402iy9jl8idxglrr73hkbd2gmw0";
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
    rev = "a0c83be21d95d053701e64a5589b0107917ab58f";
    
    sha256 = "1591n3b67y0a4df66asgfzj47nmxkg6ii99qf67j0nbjdzbwk642";
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
    rev = "d06a664ec5fa62aeaa72836a2ebe92c99b882a0f";
    
    sha256 = "0rbpv0n0v3yvkajdln7hacdq8hpyw81qhzgxvzbj9jpj512qb5nz";
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
    rev = "1de120c4cc832caa007699658fc12e7fa43a3717";
    
    sha256 = "0pqyg9iw104qmvgdlls97cjjflrqf6cl1cdsqf0jnrlfg55dpw71";
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
    rev = "943dd704c22c7f09948932200fe54d85905545e3";
    
    sha256 = "1k2wr02k8mxxfaqbynypmspxdsi7ha189b1iafdsv52sw1jq2mai";
    crates = [
      {
        name = "proxmox-openid";
        path = "proxmox-openid";
      }
    ];
  }
  {
    name = "librust-proxmox-parallel-handler-dev";
    url = "git://git.proxmox.com/git/proxmox.git";
    rev = "46350fd4c0555bfeca02021dd6cd09f5a80be718";
    
    sha256 = "1862yw538pcmlni41vybj69hkmiwhdjacgk1c3ych5j8qb03ld1d";
    crates = [
      {
        name = "proxmox-parallel-handler";
        path = "proxmox-parallel-handler";
      }
    ];
  }
  {
    name = "librust-proxmox-procfs-dev";
    url = "git://git.proxmox.com/git/proxmox.git";
    rev = "c0d55631993e3b981caa8ea6799e241fa79a66b7";
    
    sha256 = "1hcsnknsnarqpxb5dk59nc87b2b7ig8qzip82qz42flviwbk1gqf";
    crates = [
      {
        name = "proxmox-procfs";
        path = "proxmox-procfs";
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
    rev = "330f68d7f686907dd0749bb65c2268734f44b9bb";
    
    sha256 = "0kahw1ix0kvp1z9pfvqw9ilxn5d8wnwr83hf61wp0g5ylrg1r5yf";
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
    rev = "64cb179dfaa09b132de554870a45bf7d1392aca1";
    
    sha256 = "0va0455qmnhr0rsvvamib11pfsbzg8rnlswwszxncnpzswldpncx";
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
    rev = "aa6a31b22aa674f30e8b24ab2fb904b5d50ad8bb";
    
    sha256 = "08ab3bbqmm6sccki8js808ac1h1sa4fkdaljjcxhghkngrxpg2s2";
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
    rev = "89c1d597a9d15743049eadcb1add380573265904";
    
    sha256 = "1mzj8y37n3x08kqhppmj7zy497sh188aym06wi0aa85bgmvi4wa5";
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
    rev = "e6a27600f8e4362f2703fd517ed8cc51e2d039cc";
    
    sha256 = "0w8v28za4ghm1pfz2lbs9x941pfq2dgwzqps2f94jriajxklacb7";
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
    rev = "13ea4ef176d0b71ce6081ee9bb7ae3951c8a5132";
    
    sha256 = "0k9y71gdi4pvk6vm929m1qkgmdllyh99ggkrbh90xrvww79jrq86";
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
    rev = "f9d312f1bd30634d9296dfe9e501729754be4b99";
    
    sha256 = "13729gnz6daphc6qxdp83dyqmm4xbwsy04arxdfl4gnv1kl85y8d";
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
    rev = "6bd69b4c89de956f88f47b6cb8ff0e573b98d1c7";
    
    sha256 = "1m136a63mh9ik9dg556rdakpqbkrhpb4jb08bal8kr67h86264ln";
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
    rev = "5eab8145aceb20312712efa5ed1969bb826e64ab";
    
    sha256 = "1vc9bbxfagy9w6iwhcqnrify4h21phm232jl4fwniwgv3ad5i7lj";
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
    rev = "cba404ed261530491323b153512170d366077e6b";
    
    sha256 = "10nqk4j6xqnjl8y9h21w0dyhl42d7gf465icibqz5qbdn4l46y1i";
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
    rev = "9363c742a901b018e3adda3fb24e175c966235f5";
    
    sha256 = "05f9n1ggzaf75hxpisv3c3nll5yb04wyz5aky6c5cnv4lzbb36a9";
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
    rev = "e95adeb55a05016950dd26dc1934eabb6d53705d";
    
    sha256 = "0lvx8i0qwpsc8zazhdydd0isxf8wzrd5b7jyvn81400n2yg503jd";
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
    rev = "82941eaf48e008d980fdbce82fd65dd6b4869cd9";
    
    sha256 = "0kwcyn9vim4vrp29nms9sqkgvzh4dnm8zjq2lnmbdkbzwqzz08dq";
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
    rev = "5b04ced3f5d55ed823cf990e7ac7139f554fe9b2";
    
    sha256 = "1vwjbmxp8nsiwcqwbjjkij73v6bpd7i1yi728lrx62sm8dykphgv";
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
    rev = "02c2a5859201943c4cea451eeba5d91ac6816422";
    
    sha256 = "0h0iqndmpfkflv39nsna445ssr0qp9xwxpkz3v0r0w5jvs2xgx0z";
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
    rev = "28f5f5aea165558c3400e8c24436d9f2fcec3dfb";
    
    sha256 = "1mf97pyz8y0v168qakmciqljbhrfv47lz1d3zf9731jkp86ay65l";
    crates = [
      {
        name = "proxmox-time";
        path = "proxmox-time";
      }
    ];
  }
  {
    name = "librust-proxmox-upgrade-checks-dev";
    url = "git://git.proxmox.com/git/proxmox.git";
    rev = "bf2f5742a23fe24398cc062b9d04d86f8396d762";
    
    sha256 = "082x5vjal8gg5h0a1rjbgglwsxj01r75zjgl0vdvwjqx3yycxfxy";
    crates = [
      {
        name = "proxmox-upgrade-checks";
        path = "proxmox-upgrade-checks";
      }
    ];
  }
  {
    name = "librust-proxmox-uuid-dev";
    url = "git://git.proxmox.com/git/proxmox.git";
    rev = "aced6d2b7d8c47e1a5825d825ac988eac7d90c8a";
    patches = [ ../pve-yew-mobile-gui/0001-proxmox-uuid-fix-implicit-autoref.patch ];
    sha256 = "01famhymykh5l99iq5gg6rifbfn8gwxpi4zlpnihbiv83kqx6xvc";
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
    rev = "2b03260f0f6a3607b1a2b6d4910171825785235a";
    
    sha256 = "1impbykdzpky2jkkjwh6f97c4favhqdcb0ws0xpgf1xn42y8nc6b";
    crates = [
      {
        name = "proxmox-ve-config";
        path = "proxmox-ve-config";
      }
    ];
  }
  {
    name = "librust-proxmox-wireguard-dev";
    url = "git://git.proxmox.com/git/proxmox.git";
    rev = "cbe54e1cf49a96b939829989826650ea7aebad1d";
    
    sha256 = "1nqa78j6bxnh4zlxa3sdvmjj7i1ypgpyslrd420dzxwswh4mpghq";
    crates = [
      {
        name = "proxmox-wireguard";
        path = "proxmox-wireguard";
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
    rev = "713c4b5f06648b339b41d8ab23c981f479673634";
    
    sha256 = "0qwld157czx9cchj5i6sa2vbdzv8cwprhh2gmm57dfdwh1wrlzjp";
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
    rev = "253905e4f3ea2b2fc88f0eff68a65b9f04ca0929";
    
    sha256 = "0g11a0smp4sw504pg4pcpjcxzq0drmi0msqzw2m7glk2r96n7qmh";
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
    rev = "b3a5c5da12bc0479ac975cb4884414d48bde09e6";
    
    sha256 = "0jj4x8h1c5vglzg4pmzzn53hfrm7ig55k5hiva7gkxkcwh71pdfi";
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
    rev = "a5313d5fa01a513adb3dc54e5b724ad9c9b48377";
    
    sha256 = "0nk350m710x5jaclkqgrlvfzl6np82ajnh7lqjk3pcfdars7d2ij";
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
    rev = "091a8a382d0d6fc71025351fb35c51b1f3b0074d";
    
    sha256 = "1c3jcmi0kjrcpd94pxrcjzd6x1labasi0di4xbr5dfd77spna8gm";
    crates = [
      {
        name = "pxar";
        path = ".";
      }
    ];
  }
]
