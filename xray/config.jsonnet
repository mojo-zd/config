// overseas server
// He should be able to access services banned by gfw
// eg:
//  - google.com
//  - github.com
//  - ...
local overseasServer = {
  tag: 'oversea',

  address: '119.28.132.182',
  user: 'e451daf0-a8b7-4cb3-b54c-4c8c291c50a3',
  port: 4203,
  alterId: 64,
};

local clashServer = {
  tag: 'oversea',
  address: '127.0.0.1',
  port: 7897,
};


// ========= ctyun dev/prod proxy ========== //
// ctyun dev/prod env proxy
// opened by `ssh -D`
local ctyunServer = {
  tag: 'ctyun.com',

  address: '127.0.0.1',
  port: 2000,
};
// ctyunPrivateDomains
// serving from ctyunServer
local ctyunPrivateDomains = [
  'szcty.bgzs.site',
  'ctyun-szcty-dev.ctyun.cn',
];
local ctyunPrivateIPs = [
  '172.30.0.0/16',
  '10.246.39.55/32',
  '10.150.67.62/32',
  '10.50.208.198/32',
  '10.50.208.195/32',
];
// ========= ctyun dev/prod proxy ========== //


// ========= ctyun office  ========== //
local ctyunOfficeDomains = [
  '*.srdcloud.cn',  // git repo
  '*.ctc.com',  // cloudoa
  '*.chinatelecom.com.cn',
  '*.chinatelecom.cn',
  'gitlab.ctyun.cn',
];
// ========= ctyun office  ========== //


// ========= direct connect ======== //
local directlyConnectedDomains = ctyunOfficeDomains + [
  'geoip:private',
  'geoip:cn',
];
local directlyConnectedIPs = [
  '41.10.255.0/24', // git repo
  '203.55.10.36/32',  // wwwtest.ctyun.cn
  '21.57.154.134', // yunjing
  "21.40.0.0/16", // yunjing web
  'geoip:private',
  'geoip:cn',
];
// ========= direct connect ======== //

{
  // https://www.v2ray.com/chapter_02/01_overview.html#logobject
  log: {
    loglevel: 'debug',
  },
  // local server configuration
  inbounds: [
    //  http/https proxy
    {
      listen: '0.0.0.0',
      protocol: 'http',
      port: '8080',
      settings: {
        timeout: 360,
      },
    },
  ],

  outbounds: [
    // overseas server
    // {
    //   protocol: 'vmess',
    //   tag: overseasServer.tag,
    //   settings: {
    //     vnext: [
    //       {
    //         address: overseasServer.address,
    //         port: overseasServer.port,
    //         users: [
    //           {
    //             alterId: overseasServer.alterId,
    //             id: overseasServer.user,
    //             security: 'auto',
    //             level: 0,
    //           },
    //         ],
    //       },
    //     ],
    //   },
    // },

    // clash server
    {
     protocol: 'socks',
     tag: clashServer.tag,
     settings: {
       servers: [
         {
           address: clashServer.address,
           port: clashServer.port,
         },
       ],
     },
    },


    // ctyun server
    {
      protocol: 'socks',
      tag: ctyunServer.tag,
      settings: {
        servers: [
          {
            address: ctyunServer.address,
            port: ctyunServer.port,
          },
        ],
      },
    },

    // direct visit
    {
      protocol: 'freedom',
      settings: {
        domainStrategy: 'AsIs',  // https://www.v2ray.com/chapter_02/protocols/freedom.html
        userLevel: 0,
      },
      tag: 'direct',
    },
  ],

  // https://www.v2ray.com/chapter_02/03_routing.html
  routing: {
    settings: {
      domainStrategy: 'IPIfNonMatch',
      rules: [
        {
          domain: ctyunPrivateDomains,
          type: 'field',
          outboundTag: ctyunServer.tag,
        },
        {
          outboundTag: ctyunServer.tag,
          type: 'field',
          ip: ctyunPrivateIPs,
        },


        // direct visit dest server
        {
          domain: directlyConnectedDomains,
          type: 'field',
          outboundTag: 'direct',
        },
        {
          outboundTag: 'direct',
          type: 'field',
          ip: directlyConnectedIPs,
        }

        // other traffic forward to overseas (default route)
      ],
    },

  },
}
