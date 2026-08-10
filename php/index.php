<?php

// =====================================================
// iNaturalist Bird Species Card
// Mobile friendly - Tabler
// Dutch default
// Fast loading (medium image)
// Tap image for original high-resolution version
// =====================================================

$lang    = $_GET['lang'] ?? 'nl';
$species = $_GET['species'] ?? 'Falco sparverius';

$text = [

'nl' => [
    'title'        => 'Vogelsoort',
    'placeholder'  => 'Zoek een vogel...',
    'search'       => 'Zoeken',
    'common'       => 'Nederlandse naam',
    'scientific'   => 'Wetenschappelijke naam',
    'rank'         => 'Rang',
    'id'           => 'Taxon ID',
    'wikipedia'    => 'Wikipedia',
    'license'      => 'Licentie',
    'photographer' => 'Fotograaf',
    'tap'          => 'Tik op de foto voor de originele resolutie',
    'notfound'     => 'Soort niet gevonden'
],

'en' => [
    'title'        => 'Bird Species',
    'placeholder'  => 'Search a bird...',
    'search'       => 'Search',
    'common'       => 'Common name',
    'scientific'   => 'Scientific name',
    'rank'         => 'Rank',
    'id'           => 'Taxon ID',
    'wikipedia'    => 'Wikipedia',
    'license'      => 'License',
    'photographer' => 'Photographer',
    'tap'          => 'Tap the image for the original resolution',
    'notfound'     => 'Species not found'
]

];

if (!isset($text[$lang])) {
    $lang='nl';
}

function getJson($url)
{
    $context = stream_context_create([
        'http'=>[
            'header'=>"User-Agent: Ravens/1.0\r\n"
        ]
    ]);

    $json=@file_get_contents($url,false,$context);

    if($json===false){
        return false;
    }

    return json_decode($json,true);
}

// Only birds (Aves)
$url="https://api.inaturalist.org/v1/taxa?q="
    .urlencode($species)
    ."&taxon_id=3";

$data=getJson($url);

if(!$data || empty($data['results'])){
    die($text[$lang]['notfound']);
}

$taxon=$data['results'][0];

// ----------------------------------------------------
// Images
// ----------------------------------------------------

// ----------------------------------------------------
// Images
// ----------------------------------------------------

$thumb = $taxon['default_photo']['small_url']
    ?? $taxon['default_photo']['medium_url']
    ?? $taxon['default_photo']['large_url']
    ?? $taxon['default_photo']['original_url']
    ?? '';

$highres = $taxon['default_photo']['original_url'] ?? $thumb;



?>
<!doctype html>

<html lang="<?= $lang ?>">

<head>

<meta charset="utf-8">

<meta
name="viewport"
content="width=device-width, initial-scale=1">

<title><?= htmlspecialchars($species) ?></title>

<link
href="https://cdn.jsdelivr.net/npm/@tabler/core@latest/dist/css/tabler.min.css"
rel="stylesheet">

<style>

body{
    background:#f5f7fb;
}

.species-photo{
    width:100%;
    max-height:420px;
    object-fit:cover;
    cursor:pointer;
    transition:.25s;
}

.species-photo:hover{
    opacity:.9;
}

.card{
    overflow:hidden;
}

</style>

</head>

<body>

<div class="page">

<div class="container-xl py-4">

<div class="row justify-content-center">

<div class="col-lg-8 col-xl-7">

<form method="get" class="mb-4">

<input
type="hidden"
name="lang"
value="<?= $lang ?>">

<div class="input-group">

<input
class="form-control"
type="text"
name="species"
value="<?= htmlspecialchars($species) ?>"
placeholder="<?= $text[$lang]['placeholder'] ?>">

<button class="btn btn-primary">

<?= $text[$lang]['search'] ?>

</button>

</div>

</form>


<div class="mb-3 text-end">

<a
class="btn btn-sm <?= $lang=='nl'?'btn-primary':'btn-outline-primary' ?>"
href="?species=<?= urlencode($species) ?>&lang=nl">

NL

</a>

<a
class="btn btn-sm <?= $lang=='en'?'btn-primary':'btn-outline-primary' ?>"
href="?species=<?= urlencode($species) ?>&lang=en">

EN

</a>

</div>


<div class="card shadow-sm">

<?php if($thumb!=""){ ?>

<a
href="<?= htmlspecialchars($highres) ?>"
target="_blank">

<img
src="<?= htmlspecialchars($thumb) ?>"
class="species-photo"
alt="<?= htmlspecialchars($taxon['name']) ?>">

</a>

<?php } ?>

<div class="card-body">

<h2 class="card-title mb-1">

<?= htmlspecialchars($taxon['preferred_common_name'] ?? '') ?>

</h2>

<div class="text-secondary fst-italic mb-4">

<?= htmlspecialchars($taxon['name']) ?>

</div>

<div class="alert alert-info">

<?= $text[$lang]['tap'] ?>

</div>

<table class="table table-striped table-sm">

<tr>

<th width="180">

<?= $text[$lang]['common'] ?>

</th>

<td>

<?= htmlspecialchars($taxon['preferred_common_name'] ?? '') ?>

</td>

</tr>

<tr>

<th>

<?= $text[$lang]['scientific'] ?>

</th>

<td>

<i><?= htmlspecialchars($taxon['name']) ?></i>

</td>

</tr>

<tr>

<th>

<?= $text[$lang]['rank'] ?>

</th>

<td>

<?= htmlspecialchars($taxon['rank']) ?>

</td>

</tr>

<tr>

<th>

<?= $text[$lang]['id'] ?>

</th>

<td>

<?= htmlspecialchars($taxon['id']) ?>

</td>

</tr>

<tr>

<th>

<?= $text[$lang]['wikipedia'] ?>

</th>

<td>

<?php if(!empty($taxon['wikipedia_url'])){ ?>

<a
target="_blank"
href="<?= htmlspecialchars($taxon['wikipedia_url']) ?>">

Wikipedia

</a>

<?php } ?>

</td>

</tr>

<tr>

<th>

<?= $text[$lang]['photographer'] ?>

</th>

<td>

<?= htmlspecialchars($taxon['default_photo']['attribution'] ?? '') ?>

</td>

</tr>

<tr>

<th>

<?= $text[$lang]['license'] ?>

</th>

<td>

<?= htmlspecialchars($taxon['default_photo']['license_code'] ?? '') ?>

</td>

</tr>

</table>

</div>

</div>

</div>

</div>

</div>

</div>

<script src="https://cdn.jsdelivr.net/npm/@tabler/core@latest/dist/js/tabler.min.js"></script>

</body>

</html>