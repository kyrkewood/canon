import { fileURLToPath } from 'node:url';
import { buildApp } from '../lib/app.js';
import { loadConfigFile } from '../lib/config.js';

const here = (p: string) => fileURLToPath(new URL(p, import.meta.url));

buildApp(loadConfigFile(here('../canon-infra.env')), here('../lambda')).synth();
