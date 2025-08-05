[
  {
    name = "librust-perlmod-dev";
    url = "git://git.proxmox.com/git/perlmod.git";
    rev = "1544fc13d7196152409467db416f1791ed121fc3";
    patches = [ ../perlmod/remove_safe_putenv.patch ];
    sha256 = "03m75w3hz0qx05kz09fn9hgaxiyya72bxv3id4mcjj10csshhyzw";
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
    rev = "3420df88a8edf6c26264a7534a27d4105de194f7";
    patches = [ ../perlmod/remove_safe_putenv.patch ];
    sha256 = "0i26mdqgnmg119m6m4mwl256pcpgh4xk8njsi8dyl9gmf5hv8cni";
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
    rev = "891413ffb74a02d65b9e4b81b40d894e4b0700ac";

    sha256 = "06zha16dnm07ldv8lfksmynzkl9nz05nkm28nnbqfwl6nh0xcmv8";
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
    rev = "0807248c1570677517d1dcb6a01bd5439930670c";

    sha256 = "1bnsyq0yq83788anhw434lbdfv4yfrclyg5i7q9zzl8h4kzh1a7k";
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
    rev = "69298c8d20fc7d1f80e87e0043996ba8070fdacf";

    sha256 = "14f29l3l3vv45id2xj7ha8r5dnzkqd80bg11sn7am7d4fl2v5ar5";
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
    rev = "ef54afe65f64a9373593f5ecf5ac5e79015850b4";

    sha256 = "0f1y5mhz7asw93fq7hnkn2n7bfh822dn25yy1qh9xncj2vwpy9ns";
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
    rev = "5382b8ce13e429fad9349ff129f70fcff8efd672";

    sha256 = "0gl0pgrjmn6sk6biix2vv8ghzh80d9ai207ivsa13xqiwjybhsyw";
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
    rev = "c84376e2c8c81acc5f32bd230115a7114ebb92eb";

    sha256 = "0n9b3vybk3gv9dbjnvcsw56y3rqlkws9v2pb2dcxhaaqld9wqfx7";
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
    rev = "122f88d2735c644e376cec0ad3c4a123690e53de";

    sha256 = "1bspcvmljhdjkpfxkwjiq4i4q7hwv70c101fnlpcplsxczr40h46";
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
    rev = "f01f934963e5ba121874595b94d7462f78b5e10b";

    sha256 = "1gbr0wfbi1b13g55gbrhjnq1ngx0zm5mlc4940g2lac7l3z3pmmv";
    crates = [
      {
        name = "proxmox-auth-api";
        path = "proxmox-auth-api";
      }
    ];
  }
  {
    name = "librust-proxmox-borrow-dev";
    url = "git://git.proxmox.com/git/proxmox.git";
    rev = "17adc570dba41b09e0cf78b83f67aa4b123858db";

    sha256 = "1z86irrfyb1xxzqawmpp4mapdhi53c5qnxz33zgzbs0rwqcbbrlr";
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
    rev = "619c290cf8e6e99a5a7aa05ffdcf7dd30dea30bd";

    sha256 = "06bi1zq4gdz825lszy0035xf5dn6bf845b8ydrf6bs9zb3diwxsr";
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
    rev = "d469463904284d4214e803787ca5dc33e7fd9dc5";

    sha256 = "00xw94rz21qnp0nxf6pm3n0ly32l38salq7d3524xdxvyf8pnzir";
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
    rev = "2782c727471cb21b68cec2a97d702df29535760c";

    sha256 = "040v10rmqzjgmc0gq0jfxinaiyk6salqcs0jc90r764y54imwmxk";
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
    rev = "b74391cada3e92ee0949e771e853919da6481cab";

    sha256 = "1pkvq863dx72dwnyp8qr32v3vb7cbywa9a58iyfyh7gcpizqv31r";
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
    rev = "ce206f0a96f3739be868889c8c4935589beebe7a";

    sha256 = "14brga7wxs255k7icqzmk055fq1r4jr1lh221v9khfmqlnxv1mff";
    crates = [
      {
        name = "proxmox-dns-api";
        path = "proxmox-dns-api";
      }
    ];
  }
  {
    name = "librust-proxmox-http-dev";
    url = "git://git.proxmox.com/git/proxmox.git";
    rev = "6664b4150d2455012c24209538ca1261f9c2ee8b";

    sha256 = "0vs3bxgi4qg422xj7qfv3jv57das17lhjx7rggk82i7rpbixzkps";
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
    rev = "1ce7294e0654cdb91274f39e1ac5f3c08c552c94";

    sha256 = "1ns2gl2aylk63yq7i34s60fzlycskwj25h0z05wc2dw9zvijqqnv";
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
    rev = "c7f4afb3fccab547e15622b89f3c704d8868474b";

    sha256 = "0lvxah2b4m1v9q2rlmf3ajqf6wd7ldxp532vrkavy9726q0cax8r";
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
    rev = "c336cb9ab78b2bc3ebd9ab6a94e9e6f202de3ee6";

    sha256 = "1b8zl8by8rpz1bv6drq3pzpfqf98rj2yl91ldg1mgig3dmbck4db";
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
    rev = "a7ba12d0b8f201f09dbfcf69af544eec343af7c0";

    sha256 = "14hki5pnaiby564j8r0r5pvgw11hkyx00xar8rdghqk9b4ycjzxx";
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
    rev = "bd944b06f96abbf9a10e157047e7564a3f381cd9";

    sha256 = "0n6mz90yj15dv80lcd8r25l398zzzrfh8vfknyxbc9gk9yyr7964";
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
    rev = "e06277ac7a10e1e149345b4cdfa9a485acabc283";

    sha256 = "166n6igq1cs64y09k0agk4w0rkqif21j8c018h8gvkqhgd4cpycn";
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
    rev = "ee113bf244041c6adba2f5090b64c616573a56c5";

    sha256 = "0qpjjj9yar89khwwgy34py0qh2x28qvq1z9jq2agwpiqyxk729h3";
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
    rev = "afb48baca56c4567109b9231d8ca73a1f0e0e933";

    sha256 = "17iz4q8qj9www5r80xxmk41cxd1n842rlgbv3g2qan9w4l7mvki1";
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
    rev = "975f29bd7fc10a27ad1206660409e1284e35b7e0";

    sha256 = "1mishg8p15y759l8n5ld5rpbax4wllrbasy5879n0fgkmq8p7vx5";
    crates = [
      {
        name = "proxmox-network-api";
        path = "proxmox-network-api";
      }
    ];
  }
  {
    name = "librust-proxmox-notify-dev";
    url = "git://git.proxmox.com/git/proxmox.git";
    rev = "22ffd650c2fac9000f3549930c544e6100c3b1b0";

    sha256 = "1vr7lnxg0kv69kjccwyi0nyxd2dav302gnvjkxirppwn5px532g7";
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
    rev = "56763c11840926f23fcdd67cf580c02ef4e34ab6";

    sha256 = "1j69d6gaszm3w5wv17h8pnsifmv1aqdzrin2xkcvc6w3l9gs3fa3";
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
    rev = "9ae3df424e25eb7328746a4f1cc8b0b79aa7bba9";

    sha256 = "1ixx6801080nr8bjbnndbvwj5rkw0l84bfw7rxp0hhyb4xz86z9f";
    crates = [
      {
        name = "proxmox-product-config";
        path = "proxmox-product-config";
      }
    ];
  }
  {
    name = "librust-proxmox-resource-scheduling-dev";
    url = "git://git.proxmox.com/git/proxmox-resource-scheduling.git";
    rev = "ba581d98326d1a028f3eb69295dee0b8c78372ec";

    sha256 = "0bxqb1cv1hnvzsylb8cwigy8lhyq9qb89pyj3sj34j1q5810i5a9";
    crates = [
      {
        name = "proxmox-resource-scheduling";
        path = ".";
      }
    ];
  }
  {
    name = "librust-proxmox-rest-server-dev";
    url = "git://git.proxmox.com/git/proxmox.git";
    rev = "106aa95ced0e590c589886cb99f7e0424e83bfce";

    sha256 = "1cm1y89qsb20a71jypar1kfxascm1lcggmi8vsc20xgvw6f0nhfd";
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
    rev = "698b6782cd9e29669431dcc1e784cb843da9d1b4";

    sha256 = "1q8hjq86bknw86mx3id3fkkpkf46x1ny2jkvvgdy3hvgv4kqh871";
    crates = [
      {
        name = "proxmox-router";
        path = "proxmox-router";
      }
    ];
  }
  {
    name = "librust-proxmox-schema-dev";
    url = "git://git.proxmox.com/git/proxmox.git";
    rev = "e4f5179ae6a647d81ddd299b5019b6980743d018";

    sha256 = "1ih86xi1w49apgil5hkivvzka87kw6ml7w6qng1jdpcq7glj1wc6";
    crates = [
      {
        name = "proxmox-schema";
        path = "proxmox-schema";
      }
    ];
  }
  {
    name = "librust-proxmox-section-config-dev";
    url = "git://git.proxmox.com/git/proxmox.git";
    rev = "f2fefb7ffdc59497394052f90cd6a11819660d3b";

    sha256 = "0bvips03szbc7cvd41923apgnczf8sl23yv82d0j2n5aplmryr3w";
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
    rev = "043fec42f82163a1e6e7012d1032ce67c26cafdc";

    sha256 = "1dw13h1dym0xvs24l4bfi3fjkgqqqcd5p3av1656dgdfzz2x9shj";
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
    rev = "821fdb63b0f7aa3469afef3d73ef68de65b4cb8b";

    sha256 = "1pssqw6q82ly65yby913m659v0qhw33bshh09r7g6clb2md2bgvg";
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
    rev = "01947a9802f787e58167f61ff5e4867147be0bf7";

    sha256 = "09mc41cz1ba1z6c1v0hijfjl3salb25v7i6fgl623x3syh0nx5zh";
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
    rev = "aa29c548590842e7e428c3b92e01836915f482fb";

    sha256 = "0w6gp3pcdc5sg0d727bkn89h8lp8kysc24mjqz5zbyhqf8lf1myk";
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
    rev = "ed74a6a8a2b6ea40896dc26420915fa766524264";

    sha256 = "0k4jl92d8gslc8293j33664iapb2jgx1rbvl761ywg7g6l72vl8d";
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
    rev = "c83627b1a6bd69aefaeb9c3fdd8e9f2d1ff46b68";

    sha256 = "15d0lasyx8dm399dcaqbwbvrhk5jrc0kljr4vy687m1chqbszr6f";
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
    rev = "40f0a0bdd3f350e2cd6024b541b8f2eac46fe990";

    sha256 = "1nxcdc1pl6hvrk12wc7qgzrwx0l9gmnwsf3fxvz2jzsbsv6mljf2";
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
    rev = "86a517d0875acec90ca1aae71e0a795930308d6d";

    sha256 = "11gnhbyp652gkbdv89j4c79zphnjsd548cps35yxqf18ds7vwva3";
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
    rev = "e0bdcda6e60b55830284e079c1e05e34d344724f";

    sha256 = "0id0vnd3ivj73m90qj6ck7lm1ggsqqx3rbml1ailxaga9dsyqbvr";
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
    rev = "f67c6519294ba70a8d47e4b3b4a292a4835965b0";

    sha256 = "13zvkw05z49a3pjv9a0n5wkrg657iw7pc20cvsbmxjxpbp1gzmd4";
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
    rev = "7e25958623ddd38f576499bd97ced05f2ffeae22";

    sha256 = "0j5p1406b4s5ziwbhw07bv3x3nlarw6bn80vp4iq483d8zikq7zk";
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
    rev = "4be2392d59ae624ae7b871c38ef2c1c604a255ea";

    sha256 = "1y6ci9w65ab4jslg7yvsmn0wz2ab7ap92rpwx6d6skkbwqslwkbw";
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
    rev = "7200cd7e23519077f80c50d8e31bbaee7a23cd58";

    sha256 = "15c2118qbgmjrvs1zzh516rv1w5w8clfj484gasqn6y4whbyaxiv";
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
    rev = "fc7a4be4eb205edc7cb928e45771e167eb19c45e";

    sha256 = "1kq6iz08gz6l9l9p4n6r5l9ybbliz0lj8pfkk93qih2hwwa932a9";
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
    rev = "8df770662c6f8ee75cd135170992807ac2fe0abb";

    sha256 = "19zqdw2860qgh6f10am8zshpffiymbg712xl7lap9jz1bqmp8yxj";
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
    rev = "36e552de4707729481dc4009e4d60fafef1bdc64";

    sha256 = "1kxaam6bbr65j38cgr45h864schbv5c6s806m51bqis4fzs66s0r";
    crates = [
      {
        name = "proxmox-worker-task";
        path = "proxmox-worker-task";
      }
    ];
  }
]
