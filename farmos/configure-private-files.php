<?php

#ddev-generated

function appendPrivatePathFallback(string $settings_file): void {
  if (!is_file($settings_file) || is_link($settings_file)) {
    return;
  }

  $source = file_get_contents($settings_file);
  if ($source === false) {
    exit(1);
  }

  $tokens = PhpToken::tokenize($source);
  $code = array_values(array_filter($tokens, static fn (PhpToken $token) => !$token->isIgnorable()));
  for ($i = 0, $end = count($code) - 4; $i < $end; $i++) {
    if ($code[$i]->is(T_VARIABLE) && $code[$i]->text === '$settings' &&
        $code[$i + 1]->is('[') &&
        $code[$i + 2]->is(["'file_private_path'", '"file_private_path"']) &&
        $code[$i + 3]->is(']') &&
        $code[$i + 4]->is(['=', T_COALESCE_EQUAL])) {
      return;
    }
  }

  $last = end($tokens);
  $opening = $last === false || $last->is([T_CLOSE_TAG, T_INLINE_HTML]) ? "<?php\n" : "\n";
  $fallback = <<<'SETTINGS'
  // Set the default farmOS private file path.
  $settings['file_private_path'] ??= 'sites/default/private/files';
  SETTINGS;
  if (file_put_contents($settings_file, $opening . $fallback . "\n", FILE_APPEND | LOCK_EX) === false) {
    exit(1);
  }
}

appendPrivatePathFallback('web/sites/default/settings.php');

$private_dir = 'web/sites/default/private/files';
if (!is_dir($private_dir) && !mkdir($private_dir, 0777, true) && !is_dir($private_dir)) {
  exit(1);
}
